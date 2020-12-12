import Fluent
import Vapor

// TODO: this should be changed to be a real Redux like store
final class AppStore {
    var userStoriesVotes: [UserStory: UserStory.Vote] = [:]
}

func routes(_ app: Application) throws {
    app.get { req in
        GroomingSession.query(on: req.db).sort(\.$date, .descending).all().map {
            HomepageTemplate().render(with: HomepageData(groomingSessions: $0), for: req)
        }
    }

    try app.register(collection: GroomingSessionController())
    app.get("groomingSessionsContext", use: GroomingSessionController().context(req:))
    try app.register(collection: UserStoryController(store: AppStore()))
}
