import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        GroomingSession.query(on: req.db).all().map {
            HomepageTemplate().render(with: HomepageData(groomingSessions: $0), for: req)
        }
    }

    try app.register(collection: GroomingSessionController())
    app.get("groomingSessionsContext", use: GroomingSessionController().context(req:))
    try app.register(collection: UserStoryController())
}
