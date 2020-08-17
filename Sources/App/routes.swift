import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        GroomingSession.query(on: req.db).all().map {
            Homepage(
                groomingSessionContext: GroomingSessionContext(
                    groomingSessionsCount: $0.count,
                    maximumGroomingSessionsCount: GroomingSessionContext.maximumAllowed
                ),
                groomingSessions: $0
            ).render
        }
    }

    try app.register(collection: GroomingSessionController())
    app.get("groomingSessionsContext", use: GroomingSessionController().context(req:))
    try app.register(collection: UserStoryController())
}
