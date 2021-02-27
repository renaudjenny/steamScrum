import Fluent
import Vapor

// TODO: this should be changed to be a real Redux like store
// (See https://github.com/renaudjenny/steamScrum/issues/29)
final class AppStore {
    var userStoriesVotes: [UserStory.IDValue: UserStory.Vote] = [:] {
        didSet { updateCallbacks.values.forEach { $0() } }
    }

    var updateCallbacks: [UUID: () -> Void] = [:]
}

func routes(_ app: Application) throws {
    app.get { req in
        RefinementSession.query(on: req.db).sort(\.$date, .descending).all().map {
            HomepageTemplate().render(with: HomepageData(refinementSessions: $0), for: req)
        }
    }

    try app.register(collection: RefinementSessionController())
    try app.register(collection: UserStoryController())
    try app.register(collection: UserStoryVoteController(store: AppStore()))
}
