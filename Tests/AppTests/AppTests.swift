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
}
