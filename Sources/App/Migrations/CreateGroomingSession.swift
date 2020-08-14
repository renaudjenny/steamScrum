import Fluent

struct CreateGroomingSession: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("grooming_sessions")
            .id()
            .field("name", .string, .required)
            .field("date", .date, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("grooming_sessions").delete()
    }
}
