import Fluent
import Vapor

final class UserStory: Model, Content {
    static let schema = "user_stories"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Parent(key: "grooming_session_id")
    var groomingSession: GroomingSession

    init() { }

    init(id: UUID? = nil, name: String, groomingSession: GroomingSession) throws {
        self.id = id
        self.name = name
        self.$groomingSession.id = try groomingSession.requireID()
    }
}

// Structure of POST /grooming_sessions/:grooming_session_id/user_stories request.
struct PostUserStory: Decodable {
    var name: String

    func userStory(with groomingSession: GroomingSession) throws -> UserStory {
        try UserStory(name: name, groomingSession: groomingSession)
    }
}
