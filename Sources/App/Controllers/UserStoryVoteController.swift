import Fluent
import Vapor

struct UserStoryVoteController: RouteCollection {
    let store: AppStore

    func boot(routes: RoutesBuilder) throws {
        let vote = routes.grouped("grooming_sessions", ":groomingSessionID", "user_stories", ":userStoryID", "vote")
        vote.get(use: index)
        vote.get(":participant", use: voteView)
        // FIXME: addVotingParticipant should be removed at some point
        vote.post(use: addVotingParticipant)
        vote.webSocket(onUpgrade: upgrade)
    }

    private func index(req: Request) throws -> EventLoopFuture<UserStory.Vote> {
        guard let groomingSessionIdString = req.parameters.get("groomingSessionID"),
              let groomingSessionId = UUID(uuidString: groomingSessionIdString),
              let userStoryIdString = req.parameters.get("userStoryID"),
              let userStoryId = UUID(uuidString: userStoryIdString)
        else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return UserStory.query(on: req.db)
            .filter(\.$id == userStoryId)
            .with(\.$groomingSession)
            .filter(\.$groomingSession.$id == groomingSessionId)
            .first()
            .unwrap(or: Abort(.notFound))
            .map { _ in
                if !store.userStoriesVotes.keys.contains(userStoryId) {
                    store.userStoriesVotes[userStoryId] = UserStory.Vote()
                }
                return store.userStoriesVotes[userStoryId] ?? UserStory.Vote()
            }
    }

    private func voteView(req: Request) throws -> EventLoopFuture<View> {
        guard let groomingSessionIdString = req.parameters.get("groomingSessionID"),
              let groomingSessionId = UUID(uuidString: groomingSessionIdString),
              let userStoryIdString = req.parameters.get("userStoryID"),
              let userStoryId = UUID(uuidString: userStoryIdString),
              let participant = req.parameters.get("participant")
        else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return UserStory.query(on: req.db)
            .filter(\.$id == userStoryId)
            .with(\.$groomingSession)
            .filter(\.$groomingSession.$id == groomingSessionId)
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

    // TODO: this could be done directly in the WebSocket instead of doing another post request
    private func addVotingParticipant(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let participant = try req.content.decode([String: String].self)["participant"],
              !participant.isEmpty
        else { return req.eventLoop.makeFailedFuture(Abort(.badRequest)) }

        guard let groomingSessionIdString = req.parameters.get("groomingSessionID"),
              let groomingSessionId = UUID(uuidString: groomingSessionIdString),
              let userStoryIdString = req.parameters.get("userStoryID"),
              let userStoryId = UUID(uuidString: userStoryIdString)
        else { return req.eventLoop.makeFailedFuture(Abort(.badRequest)) }

        return UserStory.query(on: req.db)
            .filter(\.$id == userStoryId)
            .with(\.$groomingSession)
            .filter(\.$groomingSession.$id == groomingSessionId)
            .first()
            .unwrap(or: Abort(.notFound))
            .map { _ in
                if !store.userStoriesVotes.keys.contains(userStoryId) {
                    store.userStoriesVotes[userStoryId] = UserStory.Vote()
                }
                store.userStoriesVotes[userStoryId]?.add(participant: participant)
            }
            .transform(to: .ok)
    }

    private func upgrade(req: Request, webSocket: WebSocket) {
        guard let groomingSessionIdString = req.parameters.get("groomingSessionID"),
              let groomingSessionId = UUID(uuidString: groomingSessionIdString),
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
            .with(\.$groomingSession)
            .filter(\.$groomingSession.$id == groomingSessionId)
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
        print("Text received: \(text)")

        if text == "connection-ready" {
            onConnectionReady(webSocketId: webSocketId, userStoryId: userStoryId, webSocket: webSocket)
        } else if (text.contains("vote")) {
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
}
