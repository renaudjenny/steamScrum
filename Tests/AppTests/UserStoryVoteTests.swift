@testable import App
import XCTVapor

final class UserStoryVoteTests: XCTestCase {
    private let app = Application(.testing)
    private var groomingSession: GroomingSession?
    private var userStory: UserStory?
    private var mockedStore: AppStore?

    override func setUpWithError() throws {
        try super.setUpWithError()
        try configure(app)
        try app.autoMigrate().wait()

        mockedStore = AppStore()

        // Override the route collection to inject the mocked store
        try app.register(collection: UserStoryVoteController(store: store()))

        try app.test(.POST, "grooming_sessions", beforeRequest: { req in
            try req.content.encode([
                "name": "Session test",
                "date": DateFormatter.yyyyMMdd.string(from: Date()),
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            groomingSession = try res.content.decode(GroomingSession.self)
        })

        try app.test(.POST, "grooming_sessions/\(try groomingSessionId())/user_stories", beforeRequest: { req in
            try req.content.encode([
                "name": "User Story test",
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            userStory = try res.content.decode(UserStory.self)
        })
    }

    override func tearDown() {
        app.shutdown()
        super.tearDown()
    }

    func groomingSessionId() throws -> UUID { try XCTUnwrap(try XCTUnwrap(groomingSession).id) }
    func userStoryId() throws -> UUID { try XCTUnwrap(try XCTUnwrap(userStory).id) }
    func store() throws -> AppStore { try XCTUnwrap(mockedStore) }

    func testVoteGet() throws {
        // Check first that the store is empty
        XCTAssertEqual(try store().updateCallbacks.count, 0)

        try app.test(.GET, "grooming_sessions/\(try groomingSessionId())/user_stories/\(try userStoryId())/vote") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try store().userStoriesVotes.count, 1)
        }
    }
}
