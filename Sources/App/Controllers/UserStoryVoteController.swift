import Fluent
import Vapor

struct UserStoryVoteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let vote = routes.grouped("refinement_sessions", ":refinementSessionID", "user_stories", ":userStoryID", "vote")
        vote.get(use: index)
        vote.get(":participant", use: voteView)
        vote.webSocket("connect", onUpgrade: upgrade)
        vote.post(use: save)
        vote.delete(":voteID", use: delete)
    }

    private func index(req: Request) throws -> EventLoopFuture<UserStoryVote> {
        guard let refinementSessionIdString = req.parameters.get("refinementSessionID"),
              let refinementSessionId = UUID(uuidString: refinementSessionIdString),
              let userStoryIdString = req.parameters.get("userStoryID"),
              let userStoryId = UUID(uuidString: userStoryIdString)
        else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return UserStory.query(on: req.db)
            .filter(\.$id == userStoryId)
            .with(\.$refinementSession)
            .filter(\.$refinementSession.$id == refinementSessionId)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { userStory in
                if !req.application.userStoriesVotes.keys.contains(userStoryId) {
                    req.application.userStoriesVotes[userStoryId] = try UserStoryVote(
                        userStory: userStory
                    )
                }
                guard let userStoryVote = req.application.userStoriesVotes[userStoryId]
                else { throw Abort(.notFound) }
                return userStoryVote
            }
    }

    private func voteView(req: Request) throws -> EventLoopFuture<View> {
        guard let refinementSessionIdString = req.parameters.get("refinementSessionID"),
              let refinementSessionId = UUID(uuidString: refinementSessionIdString),
              let userStoryIdString = req.parameters.get("userStoryID"),
              let userStoryId = UUID(uuidString: userStoryIdString),
              let participant = req.parameters.get("participant")
        else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return UserStory.query(on: req.db)
            .filter(\.$id == userStoryId)
            .with(\.$refinementSession)
            .filter(\.$refinementSession.$id == refinementSessionId)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap {
                guard let userStoryId = $0.id,
                      let vote = req.application.userStoriesVotes[userStoryId],
                      vote.participants.contains(participant)
                else { return req.eventLoop.makeFailedFuture(Abort(.badRequest)) }

                return req.view.render(
                    "userStoryVote",
                    UserStoryVoteData(
                        userStoryName: $0.name,
                        refinementSessionName: $0.refinementSession.name,
                        participantName: participant
                    )
                )
            }
    }

    private func upgrade(req: Request, webSocket: WebSocket) {
        guard let refinementSessionIdString = req.parameters.get("refinementSessionID"),
              let refinementSessionId = UUID(uuidString: refinementSessionIdString),
              let userStoryIdString = req.parameters.get("userStoryID"),
              let userStoryId = UUID(uuidString: userStoryIdString)
        else {
            webSocket.send("Bad request")
            _ = webSocket.close()
            return
        }

        let webSocketId = UUID()

        webSocket.onText { onMessageReceived(
            webSocketId: webSocketId,
            userStoryId: userStoryId,
            webSocket: $0,
            text: $1,
            application: req.application
        ) }

        webSocket.onClose.whenComplete { _ in
            req.application.updateCallbacks.removeValue(forKey: webSocketId)
        }

        // If the User Story is not available, close the connection
        // If the User Story doesn't have a Vote session already, create one for it
        _ = UserStory.query(on: req.db)
            .filter(\.$id == userStoryId)
            .with(\.$refinementSession)
            .filter(\.$refinementSession.$id == refinementSessionId)
            .first()
            .flatMapThrowing { userStory in
                guard let userStory = userStory
                else {
                    webSocket.send("Error: Cannot connect to the vote you asked for")
                    _ = webSocket.close()
                    return
                }

                if !req.application.userStoriesVotes.keys.contains(userStoryId) {
                    req.application.userStoriesVotes[userStoryId] = try UserStoryVote(
                        userStory: userStory
                    )
                }
            }
    }

    private func onMessageReceived(
        webSocketId: UUID,
        userStoryId: UUID,
        webSocket: WebSocket,
        text: String,
        application: Application
    ) {
        if text == "connection-ready" {
            onConnectionReady(
                webSocketId: webSocketId,
                userStoryId: userStoryId,
                webSocket: webSocket,
                application: application
            )
        } else if text.contains("addVotingParticipant") {
            onAddVotingParticipant(
                webSocketId: webSocketId,
                userStoryId: userStoryId,
                webSocket: webSocket,
                text: text,
                application: application
            )
        } else if text.contains("vote") {
            onVote(
                webSocketId: webSocketId,
                userStoryId: userStoryId,
                webSocket: webSocket,
                text: text,
                application: application
            )
        }
    }

    private func onConnectionReady(
        webSocketId: UUID,
        userStoryId: UUID,
        webSocket: WebSocket,
        application: Application
    ) {
        application.updateCallbacks[webSocketId] = {
            let message: String
            do {
                let data = try JSONEncoder().encode(
                    application.userStoriesVotes[userStoryId]?.encoded
                )
                message = String(data: data, encoding: .utf8) ?? "Error: Cannot convert data to UTF-8 format"
            } catch {
                message = "Error: \(error)"
            }
            webSocket.send(message)
        }
        application.updateWebSockets()
    }

    private func onAddVotingParticipant(
        webSocketId: UUID,
        userStoryId: UUID,
        webSocket: WebSocket,
        text: String,
        application: Application
    ) {
        struct AddVotingParticipant: Decodable {
            var addVotingParticipant: String
        }

        do {
            guard let data = text.data(using: .utf8) else {
                webSocket.send("Error: Cannot convert '\(text)' to UTF-8 Data")
                return
            }
            let votingParticipant = try JSONDecoder().decode(AddVotingParticipant.self, from: data)

            application.userStoriesVotes[userStoryId]?.add(participant: votingParticipant.addVotingParticipant)
            application.updateWebSockets()
        } catch {
            webSocket.send("Error: \(error)")
            return
        }
    }

    private func onVote(
        webSocketId: UUID,
        userStoryId: UUID,
        webSocket: WebSocket,
        text: String,
        application: Application
    ) {
        struct SetVote: Decodable {
            struct Vote: Decodable {
                var participant: String
                var points: Int
            }
            var vote: Vote
        }

        guard let data = text.data(using: .utf8),
              let setVote = try? JSONDecoder().decode(SetVote.self, from: data)
        else { return }

        application.userStoriesVotes[userStoryId]?.set(
            points: setVote.vote.points,
            for: setVote.vote.participant
        )
        application.updateWebSockets()
    }

    private func save(req: Request) throws -> EventLoopFuture<UserStoryVote> {
        guard let refinementSessionIdString = req.parameters.get("refinementSessionID"),
              let refinementSessionId = UUID(uuidString: refinementSessionIdString),
              let userStoryIdString = req.parameters.get("userStoryID"),
              let userStoryId = UUID(uuidString: userStoryIdString)
        else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return UserStory.query(on: req.db)
            .filter(\.$id == userStoryId)
            .with(\.$refinementSession)
            .with(\.$votes)
            .filter(\.$refinementSession.$id == refinementSessionId)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { userStory -> UserStory in
                guard userStory.votes.count < UserStoryVote.maximumAllowedPerUserStory else {
                    throw Abort(.badRequest, reason: "Too many data already provided.")
                }
                return userStory
            }
            .flatMap { userStory in
                guard let vote = req.application.userStoriesVotes[userStoryId]
                else { return req.eventLoop.makeFailedFuture(Abort(.notFound)) }

                // Erase the id in case the vote is saved more than once
                vote.id = nil
                return userStory.$votes.create(vote, on: req.db)
                    .transform(to: vote)
            }
    }

    private func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let userStoryIdString = req.parameters.get("userStoryID"),
              let userStoryId = UUID(uuidString: userStoryIdString),
              let voteIdString = req.parameters.get("voteID"),
              let voteId = UUID(uuidString: voteIdString)
        else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return UserStoryVote.query(on: req.db)
            .filter(\.$id == voteId)
            .filter(\.$userStory.$id == userStoryId)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
