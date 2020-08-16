import Fluent
import Vapor

struct UserStoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userStories = routes.grouped("grooming_sessions", ":groomingSessionID", "user_stories")
        userStories.get(use: index)
        userStories.post(use: create)
//        userStories.group(":userStoryID") { groomingSession in
//            groomingSession.delete(use: delete)
//        }
    }

    func index(req: Request) throws -> EventLoopFuture<[UserStory]> {
        guard
        let groomingSessionIdString = req.parameters.get("groomingSessionID"),
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
        return GroomingSession.find(req.parameters.get("groomingSessionID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { ($0, try postUserStory.userStory(with: $0)) }
            .flatMap { groomingSession, userStory in
                groomingSession.$userStories.create(userStory, on: req.db)
                    .transform(to: userStory)
            }
    }

// TODO: Not tested yet
//    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        return UserStory.find(req.parameters.get("userStoryID"), on: req.db)
//            .unwrap(or: Abort(.notFound))
//            .flatMap { $0.delete(on: req.db) }
//            .transform(to: .ok)
//    }
}
