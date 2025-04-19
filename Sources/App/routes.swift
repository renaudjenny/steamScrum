import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req -> View in
        let refinementSessions = try await RefinementSession.query(on: req.db)
            .sort(\.$date, .descending)
            .all()
        let homepageData = HomepageData(refinementSessions: refinementSessions)
        return try await req.view.render("home", homepageData)
    }

    try app.register(collection: RefinementSessionController())
    try app.register(collection: UserStoryController())
    try app.register(collection: UserStoryVoteController())
}
