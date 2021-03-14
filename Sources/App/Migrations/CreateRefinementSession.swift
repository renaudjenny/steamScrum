import Fluent

struct CreateRefinementSession: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        // grooming_session* is used in the database because it was the old name for Refinement. But this term is inappropriate.
        // we will keep it for this version of SteamScrum. See https://github.com/renaudjenny/steamScrum/issues/34
        database.schema("grooming_sessions")
            .id()
            .field("name", .string, .required)
            .field("date", .date, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("grooming_sessions").delete()
    }
}
