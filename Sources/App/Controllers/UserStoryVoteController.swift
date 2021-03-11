import Fluent
import Vapor

struct UserStoryVoteController: RouteCollection {
    let store: AppStore

    func boot(routes: RoutesBuilder) throws {
        let vote = routes.grouped("refinement_sessions", ":refinementSessionID", "user_stories", ":userStoryID", "vote")
        vote.get(use: index)
        vote.get(":participant", use: voteView)
        vote.webSocket("connect", onUpgrade: upgrade)
        vote.post(use: save)
    }

    private func index(req: Request) throws -> EventLoopFuture<UserStory.Vote> {
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
                if !store.userStoriesVotes.keys.contains(userStoryId) {
                    store.userStoriesVotes[userStoryId] = try UserStory.Vote(
                        userStory: userStory
                    )
                }
                guard let userStoryVote = store.userStoriesVotes[userStoryId]
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
                      let vote = store.userStoriesVotes[userStoryId],
                      vote.participants.contains(participant)
                else { return req.eventLoop.makeFailedFuture(Abort(.badRequest)) }

                return UserStoryVoteTemplate().render(with: UserStoryVoteData(userStory: $0, participant: participant), for: req)
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

        // If the User Story is not available, close the connection
        _ = UserStory.query(on: req.db)
            .filter(\.$id == userStoryId)
            .with(\.$refinementSession)
            .filter(\.$refinementSession.$id == refinementSessionId)
            .first()
            .map {
                if $0 == nil {
                    webSocket.send("Error: Cannot connect to the vote you asked for")
                    _ = webSocket.close()
                }
            }

        if !store.userStoriesVotes.keys.contains(userStoryId) {
            store.userStoriesVotes[userStoryId] = UserStory.Vote()
        }

        let webSocketId = UUID()

        webSocket.onText { onMessageReceived(
            webSocketId: webSocketId,
            userStoryId: userStoryId,
            webSocket: $0,
            text: $1
        ) }

        webSocket.onClose.whenComplete { _ in
            store.updateCallbacks.removeValue(forKey: webSocketId)
        }
    }

    private func onMessageReceived(webSocketId: UUID, userStoryId: UUID, webSocket: WebSocket, text: String) {
        if text == "connection-ready" {
            onConnectionReady(webSocketId: webSocketId, userStoryId: userStoryId, webSocket: webSocket)
        } else if text.contains("addVotingParticipant") {
            onAddVotingParticipant(webSocketId: webSocketId, userStoryId: userStoryId, webSocket: webSocket, text: text)
        } else if text.contains("vote") {
            onVote(webSocketId: webSocketId, userStoryId: userStoryId, webSocket: webSocket, text: text)
        }
    }

    private func onConnectionReady(webSocketId: UUID, userStoryId: UUID, webSocket: WebSocket) {
        store.updateCallbacks[webSocketId] = {
            let message: String
            do {
                let data = try JSONEncoder().encode(store.userStoriesVotes[userStoryId]?.encoded)
                message = String(data: data, encoding: .utf8) ?? "Error: Cannot convert data to UTF-8 format"
            } catch {
                message = "Error: \(error)"
            }
            webSocket.send(message)
        }
        store.updateCallbacks[webSocketId]?()
    }

    private func onAddVotingParticipant(webSocketId: UUID, userStoryId: UUID, webSocket: WebSocket, text: String) {
        struct AddVotingParticipant: Decodable {
            var addVotingParticipant: String
        }

        do {
            guard let data = text.data(using: .utf8) else {
                webSocket.send("Error: Cannot convert '\(text)' to UTF-8 Data")
                return
            }
            let votingParticipant = try JSONDecoder().decode(AddVotingParticipant.self, from: data)

            store.userStoriesVotes[userStoryId]?.add(participant: votingParticipant.addVotingParticipant)
            store.updateCallbacks[webSocketId]?()
        } catch {
            webSocket.send("Error: \(error)")
            return
        }
    }

    private func onVote(webSocketId: UUID, userStoryId: UUID, webSocket: WebSocket, text: String) {
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

        store.userStoriesVotes[userStoryId]?.set(
            points: setVote.vote.points,
            for: setVote.vote.participant
        )
        store.updateCallbacks[webSocketId]?()
    }

    private func save(req: Request) throws -> EventLoopFuture<UserStory.Vote> {
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
            .flatMap { userStory in
                guard let vote = store.userStoriesVotes[userStoryId]
                else { return req.eventLoop.makeFailedFuture(Abort(.notFound)) }

                return userStory.$votes.create(vote, on: req.db)
                    .transform(to: vote)
            }
            // TODO: should only save a max amount of votes per US, like 5
//            .flatMapThrowing({
//                guard $0.userStories.count < UserStory.maximumAllowed else {
//                    throw Abort(.badRequest, reason: "Too many data already provided.")
//                }
//                return $0
//            })
    }
}
