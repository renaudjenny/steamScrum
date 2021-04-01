import Fluent

struct CreateRefinementSession: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("refinement_sessions")
            .id()
            .field("name", .string, .required)
            .field("date", .date, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("refinement_sessions").delete()
    }
}
