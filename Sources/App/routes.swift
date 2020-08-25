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
                groomingSessions: $0,
                formatDate: dateFormatter.string
            ).render
        }
    }

    try app.register(collection: GroomingSessionController())
    app.get("groomingSessionsContext", use: GroomingSessionController().context(req:))
    try app.register(collection: UserStoryController())
}

private var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .none
    return formatter
}()
