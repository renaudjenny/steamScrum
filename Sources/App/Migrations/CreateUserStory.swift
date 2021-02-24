import Fluent

struct CreateUserStory: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_stories")
            .id()
            .field("name", .string, .required)
            // grooming_session* is used in the database because it was the old name for Refinement. But this term is inappropriate.
            // we will keep it for this version of SteamScrum. See https://github.com/renaudjenny/steamScrum/issues/34
            .field("grooming_session_id", .uuid, .required, .references("grooming_sessions", .id))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_stories").delete()
    }
}
