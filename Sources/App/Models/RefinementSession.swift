import Fluent
import Vapor

final class RefinementSession: Model, Content {
    // grooming_session* is used in the database because it was the old name for Refinement. But this term is inappropriate.
    // we will keep it for this version of SteamScrum. See https://github.com/renaudjenny/steamScrum/issues/34
    static let schema = "grooming_sessions"

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
