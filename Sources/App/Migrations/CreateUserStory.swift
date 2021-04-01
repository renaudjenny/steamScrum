import Fluent

struct CreateUserStory: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_stories")
            .id()
            .field("name", .string, .required)
            .field("refinement_session_id", .uuid, .required, .references("refinement_sessions", .id))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_stories").delete()
    }
}
