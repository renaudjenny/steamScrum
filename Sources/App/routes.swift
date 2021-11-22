import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        RefinementSession.query(on: req.db).sort(\.$date, .descending).all().map { _ in
            req.view.render("home")
        }
    }

    try app.register(collection: RefinementSessionController())
    try app.register(collection: UserStoryController())
    try app.register(collection: UserStoryVoteController())
}
