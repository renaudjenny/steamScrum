import Fluent
import Vapor
import QRCodeGenerator

struct UserStoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userStories = routes.grouped("grooming_sessions", ":groomingSessionID", "user_stories")
        userStories.get(use: index)
        userStories.post(use: create)
        userStories.group(":userStoryID") { userStory in
            userStory.get(use: get)
            userStory.delete(use: delete)
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
                let address = "https://\(req.application.http.server.configuration.hostname)\(req.url.string)"
                let QRCodeSVG = (try? QRCode.encode(text: address, ecl: .medium))?.toSVGString(border: 4, width: 200)
                return UserStoryTemplate().render(with: UserStoryData(userStory: $0, QRCodeSVG: QRCodeSVG), for: req)
            }
    }
}
