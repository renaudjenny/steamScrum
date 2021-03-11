@testable import App
import XCTVapor

final class UserStoryVoteTests: XCTestCase {
    private let app = Application(.testing)
    private var refinementSession: RefinementSession?
    private var userStory: UserStory?
    private var mockedStore: AppStore?

    override func setUpWithError() throws {
        try super.setUpWithError()
        try configure(app)
        try app.autoMigrate().wait()

        mockedStore = AppStore()

        // Override the route collection to inject the mocked store
        try app.register(collection: UserStoryVoteController(store: store()))

        try app.test(.POST, "refinement_sessions", beforeRequest: { req in
            try req.content.encode([
                "name": "Session test",
                "date": DateFormatter.yyyyMMdd.string(from: Date()),
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            refinementSession = try res.content.decode(RefinementSession.self)
        })

        try app.test(.POST, "refinement_sessions/\(try refinementSessionId())/user_stories", beforeRequest: { req in
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

    func refinementSessionId() throws -> UUID { try XCTUnwrap(try XCTUnwrap(refinementSession).id) }
    func userStoryId() throws -> UUID { try XCTUnwrap(try XCTUnwrap(userStory).id) }
    func store() throws -> AppStore { try XCTUnwrap(mockedStore) }

    func testVoteGet() throws {
        // Check first that the store is empty
        XCTAssertEqual(try store().userStoriesVotes.count, 0)

        try app.test(.GET, "refinement_sessions/\(try refinementSessionId())/user_stories/\(try userStoryId())/vote") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try store().userStoriesVotes.count, 1)
        }
    }

    func testVoteView() throws {
        // Mock that a participant has already been added to the store
        try store().userStoriesVotes[try userStoryId()] = UserStory.Vote(
            userStory: try XCTUnwrap(userStory),
            participants: ["Mario"],
            points: [:]
        )

        try app.test(.GET, "refinement_sessions/\(try refinementSessionId())/user_stories/\(try userStoryId())/vote/Mario") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }

    func testVoteViewWithoutValidParticipant() throws {
        try app.test(.GET, "refinement_sessions/\(try refinementSessionId())/user_stories/\(try userStoryId())/vote/Mario") { res in
            XCTAssertEqual(res.status, .badRequest)
        }

        try store().userStoriesVotes[try userStoryId()] = UserStory.Vote(
            userStory: try XCTUnwrap(userStory),
            participants: ["Luigi"],
            points: [:]
        )

        try app.test(.GET, "refinement_sessions/\(try refinementSessionId())/user_stories/\(try userStoryId())/vote/Mario") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testSaveVote() throws {
        // Mock that a participant has already been added to the store
        try store().userStoriesVotes[try userStoryId()] = UserStory.Vote(
            userStory: try XCTUnwrap(userStory),
            participants: ["Mario", "Luigi"],
            points: ["Mario": 3, "Luigi": 5]
        )

        try app.test(.POST, "refinement_sessions/\(try refinementSessionId())/user_stories/\(try userStoryId())/vote") { res in
            XCTAssertEqual(res.status, .ok)
            let userStoryVote = try XCTUnwrap(res.content.decode(UserStory.Vote.self))
            XCTAssert(userStoryVote.participants.contains("Mario"), "Mario should be a participant")
            XCTAssert(userStoryVote.participants.contains("Luigi"), "Luigi should be a participant")
            XCTAssertEqual(userStoryVote.points["Mario"], 3, "Mario points should be 3")
            XCTAssertEqual(userStoryVote.points["Luigi"], 5, "Mario points should be 5")
        }
    }
}
