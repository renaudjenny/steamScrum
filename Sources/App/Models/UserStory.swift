import Fluent
import Vapor

final class UserStory: Model, Content, Hashable {
    static let schema = "user_stories"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Children(for: \.$userStory)
    var votes: [Vote]

    // grooming_session* is used in the database because it was the old name for Refinement. But this term is inappropriate.
    // we will keep it for this version of SteamScrum. See https://github.com/renaudjenny/steamScrum/issues/34
    @Parent(key: "grooming_session_id")
    var refinementSession: RefinementSession

    init() { }

    init(id: UUID? = nil, name: String, refinementSession: RefinementSession) throws {
        self.id = id
        self.name = name
        self.$refinementSession.id = try refinementSession.requireID()
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    static func == (lhs: UserStory, rhs: UserStory) -> Bool {
        lhs.id == rhs.id
    }
}

extension UserStory {
    static let maximumAllowed = 20
}

// Structure of POST /refinement_sessions/:refinement_session_id/user_stories request.
struct PostUserStory: Decodable {
    var name: String

    func userStory(with refinementSession: RefinementSession) throws -> UserStory {
        try UserStory(name: name, refinementSession: refinementSession)
    }
}
