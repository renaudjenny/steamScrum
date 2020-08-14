import Fluent
import Vapor

final class GroomingSession: Model, Content {
    static let schema = "grooming_sessions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "date")
    var date: Date

    init() { }

    init(id: UUID? = nil, name: String, date: Date) {
        self.id = id
        self.name = name
        self.date = date
    }
}
