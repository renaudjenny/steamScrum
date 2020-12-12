import Fluent
import Vapor

struct UserStoryController: RouteCollection {
    let store: AppStore

    func boot(routes: RoutesBuilder) throws {
        let userStories = routes.grouped("grooming_sessions", ":groomingSessionID", "user_stories")
        userStories.get(use: index)
        userStories.post(use: create)
        userStories.group(":userStoryID") { userStory in
            userStory.get(use: get)
            userStory.delete(use: delete)
            userStory.group("vote") { vote in
                vote.get(use: getVote)
                vote.post(use: addVotingParticipant)
                vote.webSocket(onUpgrade: upgradeVoteWebSocket)
            }
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[UserStory]> {
        guard let groomingSessionIdString = req.parameters.get("groomingSessionID"),
              let groomingSessionId = UUID(uuidString: groomingSessionIdString)
        else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return GroomingSession.query(on: req.db)
            .filter(\.$id == groomingSessionId)
            .with(\.$userStories)
            .first()
            .unwrap(or: Abort(.notFound))
            .map { $0.userStories }
    }

    func create(req: Request) throws -> EventLoopFuture<UserStory> {
        let postUserStory = try req.content.decode(PostUserStory.self)
        guard !postUserStory.name.isEmpty else { return req.eventLoop.makeFailedFuture(Abort(.badRequest)) }
        guard let groomingSessionIdString = req.parameters.get("groomingSessionID"),
              let groomingSessionId = UUID(uuidString: groomingSessionIdString)
        else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return GroomingSession.query(on: req.db)
            .filter(\.$id == groomingSessionId)
            .with(\.$userStories)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing({
                guard $0.userStories.count < UserStoryContext.maximumAllowed else {
                    throw Abort(.badRequest, reason: "Too many data already provided.")
                }
                return $0
            })
            .flatMapThrowing { ($0, try postUserStory.userStory(with: $0)) }
            .flatMap { groomingSession, userStory in
                groomingSession.$userStories.create(userStory, on: req.db)
                    .transform(to: userStory)
            }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let groomingSessionIdString = req.parameters.get("groomingSessionID"),
              let groomingSessionId = UUID(uuidString: groomingSessionIdString),
              let userStoryIdString = req.parameters.get("userStoryID"),
              let userStoryId = UUID(uuidString: userStoryIdString)
        else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return UserStory.query(on: req.db)
            .filter(\.$id == userStoryId)
            .filter(\.$groomingSession.$id == groomingSessionId)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }

    func get(req: Request) throws -> EventLoopFuture<View> {
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
            .flatMap {
                UserStoryTemplate().render(with: UserStoryData(userStory: $0), for: req)
            }
    }

    func getVote(req: Request) throws -> EventLoopFuture<UserStory.Vote> {
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

    func addVotingParticipant(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        print("addVotingParticipant called")
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

    func upgradeVoteWebSocket(req: Request, webSocket: WebSocket) {
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
                    webSocket.send("Cannot connect to the vote you asked for")
                    _ = webSocket.close()
                }
            }

        if !store.userStoriesVotes.keys.contains(userStoryId) {
            store.userStoriesVotes[userStoryId] = UserStory.Vote()
        }

        let webSocketId = UUID()

        webSocket.onText { ws, text in
            print("Text received: \(text)")

            if text == "connection-ready" {
                store.updateCallbacks[webSocketId] = {
                    ws.send("New fresh data from the store!")
                    guard let data = try? JSONEncoder().encode(store.userStoriesVotes[userStoryId]),
                          let dataAsString = String(data: data, encoding: .utf8)
                    else {
                        ws.send("Error")
                        return
                    }
                    ws.send(dataAsString)
                }
                store.updateCallbacks[webSocketId]?()
            }
        }

        webSocket.onClose.whenComplete { _ in
            store.updateCallbacks.removeValue(forKey: webSocketId)
        }
    }
}
