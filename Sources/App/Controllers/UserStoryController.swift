import Fluent
import Vapor
import QRCodeGenerator

struct UserStoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userStories = routes.grouped("refinement_sessions", ":refinementSessionID", "user_stories")
        userStories.get(use: index)
        userStories.post(use: create)
        userStories.group(":userStoryID") { userStory in
            userStory.get(use: get)
            userStory.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[UserStory]> {
        guard let refinementSessionIdString = req.parameters.get("refinementSessionID"),
              let refinementSessionId = UUID(uuidString: refinementSessionIdString)
        else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return RefinementSession.query(on: req.db)
            .filter(\.$id == refinementSessionId)
            .with(\.$userStories)
            .first()
            .unwrap(or: Abort(.notFound))
            .map { $0.userStories }
    }

    func create(req: Request) throws -> EventLoopFuture<UserStory> {
        let postUserStory = try req.content.decode(PostUserStory.self)
        guard !postUserStory.name.isEmpty else { return req.eventLoop.makeFailedFuture(Abort(.badRequest)) }
        guard let refinementSessionIdString = req.parameters.get("refinementSessionID"),
              let refinementSessionId = UUID(uuidString: refinementSessionIdString)
        else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return RefinementSession.query(on: req.db)
            .filter(\.$id == refinementSessionId)
            .with(\.$userStories)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing({
                guard $0.userStories.count < UserStory.maximumAllowed else {
                    throw Abort(.badRequest, reason: "Too many data already provided.")
                }
                return $0
            })
            .flatMapThrowing { ($0, try postUserStory.userStory(with: $0)) }
            .flatMap { refinementSession, userStory in
                refinementSession.$userStories.create(userStory, on: req.db)
                    .transform(to: userStory)
            }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let refinementSessionIdString = req.parameters.get("refinementSessionID"),
              let refinementSessionId = UUID(uuidString: refinementSessionIdString),
              let userStoryIdString = req.parameters.get("userStoryID"),
              let userStoryId = UUID(uuidString: userStoryIdString)
        else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return UserStory.query(on: req.db)
            .filter(\.$id == userStoryId)
            .filter(\.$refinementSession.$id == refinementSessionId)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }

    func get(req: Request) throws -> EventLoopFuture<View> {
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
            .with(\.$votes)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { userStory -> UserStory in
                try populateParticipants(req: req, userStory: userStory)
                return userStory
            }
            .flatMap {
                let refinementSessionPath = req.url.string.pathComponents
                    .dropLast(2)
                    .map(\.description)
                    .joined(separator: "/")
                let refinementSessionURL = "\(req.application.environment.host)/\(refinementSessionPath)"
                let address = "\(req.application.environment.host)\(req.url.string)"
                let QRCodeSVG = (try? QRCode.encode(text: address, ecl: .medium))?
                    .toSVGString(border: 4, width: 200)
                return req.view.render("userStory", $0.viewData(
                    refinementSessionURL: refinementSessionURL,
                    QRCodeSVG: QRCodeSVG
                ))
            }
    }

    private func populateParticipants(req: Request, userStory: UserStory) throws {
        if req.application.userStoriesVotes[userStory.id!]?.participants.count == 0 {
            let participants = req.application
                .refinementSessionParticipants[userStory.refinementSession.id!] ?? []

            struct CannotRetrieveUserStoryId: Error {}
            guard let userStoryId = userStory.id else { throw CannotRetrieveUserStoryId() }

            req.application.userStoriesVotes[userStoryId] = try UserStoryVote(
                userStory: userStory,
                participants: participants,
                points: [:],
                date: Date()
            )
        }
    }
}
