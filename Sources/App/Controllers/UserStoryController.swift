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

    func index(req: Request) async throws -> [UserStory] {
        guard let refinementSessionIdString = req.parameters.get("refinementSessionID"),
              let refinementSessionId = UUID(uuidString: refinementSessionIdString)
        else {
            throw Abort(.badRequest)
        }

        guard let refinementSession = try await RefinementSession.query(on: req.db)
            .filter(\.$id == refinementSessionId)
            .with(\.$userStories)
            .first()
        else { throw Abort(.notFound) }
        return refinementSession.userStories
    }

    func create(req: Request) async throws -> UserStory {
        let postUserStory = try req.content.decode(PostUserStory.self)
        guard !postUserStory.name.isEmpty else { throw Abort(.badRequest) }
        guard let refinementSessionIdString = req.parameters.get("refinementSessionID"),
              let refinementSessionId = UUID(uuidString: refinementSessionIdString)
        else { throw Abort(.badRequest) }

        guard let refinementSession = try await RefinementSession.query(on: req.db)
            .filter(\.$id == refinementSessionId)
            .with(\.$userStories)
            .first()
        else { throw Abort(.notFound) }
        guard refinementSession.userStories.count < UserStory.maximumAllowed
        else { throw Abort(.badRequest, reason: "Too many data already provided.") }
        let userStory = try postUserStory.userStory(with: refinementSession)
        try await refinementSession.$userStories.create(userStory, on: req.db)
        return userStory
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let refinementSessionIdString = req.parameters.get("refinementSessionID"),
              let refinementSessionId = UUID(uuidString: refinementSessionIdString),
              let userStoryIdString = req.parameters.get("userStoryID"),
              let userStoryId = UUID(uuidString: userStoryIdString)
        else { throw Abort(.badRequest) }

        guard let userStory = try await UserStory.query(on: req.db)
            .filter(\.$id == userStoryId)
            .filter(\.$refinementSession.$id == refinementSessionId)
            .first()
        else { throw Abort(.notFound) }
        try await userStory.delete(on: req.db)
        return .ok
    }

    func get(req: Request) async throws -> View {
        guard let refinementSessionIdString = req.parameters.get("refinementSessionID"),
              let refinementSessionId = UUID(uuidString: refinementSessionIdString),
              let userStoryIdString = req.parameters.get("userStoryID"),
              let userStoryId = UUID(uuidString: userStoryIdString)
        else { throw Abort(.badRequest) }

        guard let userStory = try await UserStory.query(on: req.db)
            .filter(\.$id == userStoryId)
            .with(\.$refinementSession)
            .filter(\.$refinementSession.$id == refinementSessionId)
            .with(\.$votes)
            .first()
        else { throw Abort(.notFound) }
        try populateParticipants(req: req, userStory: userStory)
        let refinementSessionPath = req.url.string.pathComponents
            .dropLast(2)
            .map(\.description)
            .joined(separator: "/")
        let refinementSessionURL = "\(req.application.environment.host)/\(refinementSessionPath)"
        let address = "\(req.application.environment.host)\(req.url.string)"
        let QRCodeSVG = (try? QRCode.encode(text: address, ecl: .medium))?
            .toSVGString(border: 4, width: 200)
        return try await req.view.render("userStory", userStory.viewData(
            refinementSessionURL: refinementSessionURL,
            QRCodeSVG: QRCodeSVG
        ))
    }

    private func populateParticipants(req: Request, userStory: UserStory) throws {
        struct CannotRetrieveUserStoryId: Error {}
        struct CannotRetrieveRefinementSessionId: Error {}

        guard let userStoryId = userStory.id else { throw CannotRetrieveUserStoryId() }
        guard let refinementSessionId = userStory.refinementSession.id else {
            throw CannotRetrieveRefinementSessionId()
        }

        let currentParticipants = req.application.userStoriesVotes[userStoryId]?.participants ?? []

        let participants = req.application
            .refinementSessionParticipants[refinementSessionId] ?? []
        + currentParticipants

        req.application.userStoriesVotes[userStoryId] = try UserStoryVote(
            userStory: userStory,
            participants: participants,
            points: req.application.userStoriesVotes[userStoryId]?.points ?? [:],
            date: Date()
        )
    }
}
