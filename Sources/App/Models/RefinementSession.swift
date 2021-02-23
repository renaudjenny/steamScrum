import Fluent
import Vapor

final class RefinementSession: Model, Content {
    static let schema = "refinement_sessions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "date")
    var date: Date

    @Children(for: \.$refinementSession)
    var userStories: [UserStory]

    init() { }

    init(id: UUID? = nil, name: String, date: Date) {
        self.id = id
        self.name = name
        self.date = date
    }
}

extension RefinementSession {
    static let maximumAllowed = 250
}
