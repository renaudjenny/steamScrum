@testable import App
import XCTVapor

final class GroomingSessionTests: XCTestCase {
    private let app = Application(.testing)

    override func setUpWithError() throws {
        try super.setUpWithError()
        try configure(app)
        try app.autoMigrate().wait()
    }

    override func tearDown() {
        app.shutdown()
        super.tearDown()
    }

    func testGroomingSessionsGet() throws {
        try app.test(.GET, "grooming_sessions") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "[]")
        }
    }

    func testGroomingSessionsPost() throws {
        let groomingSessionName = "Session for POST"
        let groomingSessionDate = Date(timeIntervalSince1970: 1.0)

        try app.test(.POST, "grooming_sessions", beforeRequest: { req in
            try req.content.encode([
                "name": groomingSessionName,
                "date": ISO8601DateFormatter().string(from: groomingSessionDate)
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let receivedGroomingSession = try res.content.decode(GroomingSession.self)
            XCTAssertEqual(receivedGroomingSession.name, groomingSessionName)
            XCTAssertEqual(receivedGroomingSession.date, groomingSessionDate)
        })
    }

    func testGroomingSessionsContextGet() throws {
        let maximumGroomingSessionsCount = GroomingSessionContext.maximumAllowed

        try app.test(.GET, "groomingSessionsContext") { res in
            let context = try res.content.decode(GroomingSessionContext.self)
            XCTAssertEqual(context.groomingSessionsCount, 0)
            XCTAssertEqual(context.maximumGroomingSessionsCount, maximumGroomingSessionsCount)
        }

        try app.test(.POST, "grooming_sessions", beforeRequest: { req in
            try req.content.encode([
                "name": "Session 1",
                "date": ISO8601DateFormatter().string(from: Date())
            ])
        })
        try app.test(.GET, "groomingSessionsContext") { res in
            let context = try res.content.decode(GroomingSessionContext.self)
            XCTAssertEqual(context.groomingSessionsCount, 1)
        }

        for i in 0..<10 {
            try app.test(.POST, "grooming_sessions", beforeRequest: { req in
                try req.content.encode([
                    "name": "Session \(i + 2)",
                    "date": ISO8601DateFormatter().string(from: Date())
                ])
            })
        }
        try app.test(.GET, "groomingSessionsContext") { res in
            let context = try res.content.decode(GroomingSessionContext.self)
            XCTAssertEqual(context.groomingSessionsCount, 11)
        }
    }

    func testMaximumGroomingSessionsPost() throws {
        for i in 0..<GroomingSessionContext.maximumAllowed {
            try app.test(.POST, "grooming_sessions", beforeRequest: { req in
                try req.content.encode([
                    "name": "Session \(i + 1)",
                    "date": ISO8601DateFormatter().string(from: Date())
                ])
            })
        }

        try app.test(.GET, "grooming_sessions") { res in
            let groomingSessions = try res.content.decode([GroomingSession].self)
            XCTAssertEqual(groomingSessions.count, GroomingSessionContext.maximumAllowed)
        }

        try app.test(.POST, "grooming_sessions", beforeRequest: { req in
            try req.content.encode([
                "name": "Session ... too much",
                "date": ISO8601DateFormatter().string(from: Date())
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })
    }

    func testGroomingSessionsWithoutNamePost() throws {
        try app.test(.POST, "grooming_sessions", beforeRequest: { req in
            try req.content.encode([
                "date": ISO8601DateFormatter().string(from: Date())
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })

        try app.test(.POST, "grooming_sessions", beforeRequest: { req in
            try req.content.encode([
                "name": "",
                "date": ISO8601DateFormatter().string(from: Date())
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })
    }

    func testGroomingSessionDelete() throws {
        var id: UUID?
        try app.test(.POST, "grooming_sessions", beforeRequest: { req in
            try req.content.encode([
                "name": "Session to delete",
                "date": ISO8601DateFormatter().string(from: Date())
            ])
        }, afterResponse: { res in
            let groomingSession = try res.content.decode(GroomingSession.self)
            XCTAssertNotNil(groomingSession.id)
            id = groomingSession.id
        })

        try app.test(.GET, "grooming_sessions") { res in
            let groomingSessions = try res.content.decode([GroomingSession].self)
            XCTAssertEqual(groomingSessions.count, 1)
        }

        let groomingSessionId = try XCTUnwrap(id)
        try app.test(.DELETE, "grooming_sessions/\(groomingSessionId)") { res in
            XCTAssertEqual(res.status, .ok)
        }

        try app.test(.GET, "grooming_sessions") { res in
            let groomingSessions = try res.content.decode([GroomingSession].self)
            XCTAssertEqual(groomingSessions.count, 0)
        }
    }
}
