import Fluent

struct CreateUserStoryVote: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_story_votes")
            .id()
            .field("participants", .array(of: .string), .required)
            .field("points", .dictionary(of: .int), .required)
            .field("user_story_id", .uuid, .required, .references("user_stories", .id))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_story_votes").delete()
    }
}
