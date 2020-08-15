@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testGroomingSessionsGet() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        try app.autoMigrate().wait()

        try app.test(.GET, "grooming_sessions") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "[]")
        }
    }

    func testGroomingSessionsPost() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        try app.autoMigrate().wait()

        let groomingSessionName = "Grooming test GET"
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

    func testGetGroomingSessionsContext() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        try app.autoMigrate().wait()

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
}
