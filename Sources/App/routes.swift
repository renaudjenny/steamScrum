import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        GroomingSession.query(on: req.db).all().map {
            Homepage(
                groomingSessionContext: GroomingSessionContext(
                    groomingSessionsCount: 42,
                    maximumGroomingSessionsCount: 69
                ),
                groomingSessions: $0
            ).render
        }
    }

    try app.register(collection: GroomingSessionController())
    app.get("groomingSessionsContext", use: GroomingSessionController().context(req:))
    try app.register(collection: UserStoryController())
}
