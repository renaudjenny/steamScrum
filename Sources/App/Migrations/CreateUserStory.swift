import Fluent

struct CreateUserStory: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_stories")
            .id()
            .field("name", .string, .required)
            .field("grooming_session_id", .uuid, .required, .references("grooming_sessions", .id))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_stories").delete()
    }
}
