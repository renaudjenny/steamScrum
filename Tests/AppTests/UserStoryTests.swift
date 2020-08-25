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
                "date": DateFormatter.yyyyMMdd.string(from: Date())
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
            let receivedUserStory = try res.content.decode(UserStory.self)
            XCTAssertEqual(receivedUserStory.name, userStoryName)
        })

        try app.test(.GET, "grooming_sessions/\(try groomingSessionId())/user_stories") { res in
            XCTAssertEqual(res.status, .ok)
            let userStories = try res.content.decode([UserStory].self)
            XCTAssertEqual(userStories.count, 1)
            XCTAssertEqual(userStories.first?.name, userStoryName)
        }
    }

    func testUserStoryPostAnEmptyName() throws {
        let userStoryName = ""

        try app.test(.POST, "grooming_sessions/\(try groomingSessionId())/user_stories", beforeRequest: { req in
            try req.content.encode([
                "name": userStoryName
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })
    }

    func testMaximumUserStoryPost() throws {
        for i in 0..<UserStoryContext.maximumAllowed {
            try app.test(.POST, "grooming_sessions/\(try groomingSessionId())/user_stories", beforeRequest: { req in
                try req.content.encode([
                    "name": "User Story \(i + 1)"
                ])
            })
        }

        try app.test(.GET, "grooming_sessions/\(try groomingSessionId())/user_stories") { res in
            let userStories = try res.content.decode([UserStory].self)
            XCTAssertEqual(userStories.count, UserStoryContext.maximumAllowed)
        }

        try app.test(.POST, "grooming_sessions/\(try groomingSessionId())/user_stories", beforeRequest: { req in
            try req.content.encode([
                "name": "User Story ... too much"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })
    }

    func testUserStoryDelete() throws {
        var id: UUID?
        try app.test(.POST, "grooming_sessions/\(try groomingSessionId())/user_stories", beforeRequest: { req in
            try req.content.encode([
                "name": "User Story to delete"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let receivedUserStory = try res.content.decode(UserStory.self)
            id = receivedUserStory.id
        })

        try app.test(.GET, "grooming_sessions/\(try groomingSessionId())/user_stories") { res in
            XCTAssertEqual(res.status, .ok)
            let userStories = try res.content.decode([UserStory].self)
            XCTAssertEqual(userStories.count, 1)
        }

        let userStoryId = try XCTUnwrap(id)
        try app.test(.DELETE, "grooming_sessions/\(try groomingSessionId())/user_stories/\(userStoryId)") { res in
            XCTAssertEqual(res.status, .ok)
        }

        try app.test(.GET, "grooming_sessions/\(try groomingSessionId())/user_stories") { res in
            let userStories = try res.content.decode([UserStory].self)
            XCTAssertEqual(userStories.count, 0)
        }
    }

    func testUserStoryCannotDeleteFromAnotherUserStory() throws {
        var id: UUID?
        try app.test(.POST, "grooming_sessions/\(try groomingSessionId())/user_stories", beforeRequest: { req in
            try req.content.encode([
                "name": "User Story to delete"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let receivedUserStory = try res.content.decode(UserStory.self)
            id = receivedUserStory.id
        })

        var anotherGroomingSessionId: UUID?
        try app.test(.POST, "grooming_sessions", beforeRequest: { req in
            try req.content.encode([
                "name": "Another Session",
                "date": DateFormatter.yyyyMMdd.string(from: Date())
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            anotherGroomingSessionId = try res.content.decode(GroomingSession.self).id
        })

        try app.test(.GET, "grooming_sessions/\(XCTUnwrap(anotherGroomingSessionId))/user_stories") { res in
            XCTAssertEqual(res.status, .ok)
            let userStories = try res.content.decode([UserStory].self)
            XCTAssertEqual(userStories.count, 0)
        }

        let userStoryId = try XCTUnwrap(id)
        try app.test(.DELETE, "grooming_sessions/\(XCTUnwrap(anotherGroomingSessionId))/user_stories/\(userStoryId)") { res in
            XCTAssertEqual(res.status, .notFound)
        }

        try app.test(.GET, "grooming_sessions/\(try groomingSessionId())/user_stories") { res in
            let userStories = try res.content.decode([UserStory].self)
            XCTAssertEqual(userStories.count, 1)
        }
    }

}
