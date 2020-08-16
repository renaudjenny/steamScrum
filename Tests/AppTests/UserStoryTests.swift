@testable import App
import XCTVapor

final class UserStoryTests: XCTestCase {
    private let app = Application(.testing)
    private var groomingSession: GroomingSession?

    override func setUpWithError() throws {
        try super.setUpWithError()
        try configure(app)
        try app.autoMigrate().wait()

        try app.test(.POST, "grooming_sessions", beforeRequest: { req in
            try req.content.encode([
                "name": "Session test",
                "date": ISO8601DateFormatter().string(from: Date())
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            groomingSession = try res.content.decode(GroomingSession.self)
        })
    }

    override func tearDown() {
        app.shutdown()
        super.tearDown()
    }

    func groomingSessionId() throws -> UUID { try XCTUnwrap((try XCTUnwrap(groomingSession)).id) }

    func testUserStoriesGet() throws {
        try app.test(.GET, "grooming_sessions/\(try groomingSessionId())/user_stories") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "[]")
        }
    }

    func testUserStoryPost() throws {
        let userStoryName = "User Story"

        try app.test(.POST, "grooming_sessions/\(try groomingSessionId())/user_stories", beforeRequest: { req in
            try req.content.encode([
                "name": userStoryName
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let receivedGroomingSession = try res.content.decode(UserStory.self)
            XCTAssertEqual(receivedGroomingSession.name, userStoryName)
        })

        try app.test(.GET, "grooming_sessions/\(try groomingSessionId())/user_stories") { res in
            XCTAssertEqual(res.status, .ok)
            let userStories = try res.content.decode([UserStory].self)
            XCTAssertEqual(userStories.count, 1)
            XCTAssertEqual(userStories.first?.name, userStoryName)
        }
    }
}
