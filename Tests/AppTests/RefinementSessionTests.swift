@testable import App
import XCTVapor

final class RefinementSessionTests: XCTestCase {
    private var app: Application!

    override func setUp() async throws {
        try await super.setUp()
        app = try await Application.make(.testing)
        try configure(app)
        try await app.autoMigrate()
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
        try await super.tearDown()
    }

    func testRefinementSessionsGet() throws {
        try app.test(.GET, "refinement_sessions") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "[]")
        }
    }

    func testRefinementSessionsPost() throws {
        let refinementSessionName = "Session for POST"
        let refinementSessionDate = Date(timeIntervalSince1970: 0)

        try app.test(.POST, "refinement_sessions", beforeRequest: { req in
            try req.content.encode([
                "name": refinementSessionName,
                "date": DateFormatter.yyyyMMdd.string(from: refinementSessionDate),
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let receivedRefinementSession = try res.content.decode(RefinementSession.self)
            XCTAssertEqual(receivedRefinementSession.name, refinementSessionName)
            XCTAssertEqual(receivedRefinementSession.date, refinementSessionDate)
        })
    }

    func testRefinementSessionsContextGet() throws {
        let maximumRefinementSessionsCount = RefinementSession.maximumAllowed

        try app.test(.GET, "refinement_sessions/context") { res in
            let context = try res.content.decode(RefinementSessionController.Context.self)
            XCTAssertEqual(context.count, 0)
            XCTAssertEqual(context.maximum, maximumRefinementSessionsCount)
        }

        try app.test(.POST, "refinement_sessions", beforeRequest: { req in
            try req.content.encode([
                "name": "Session 1",
                "date": DateFormatter.yyyyMMdd.string(from: Date()),
            ])
        })
        try app.test(.GET, "refinement_sessions/context") { res in
            let context = try res.content.decode(RefinementSessionController.Context.self)
            XCTAssertEqual(context.count, 1)
        }

        for i in 0..<10 {
            try app.test(.POST, "refinement_sessions", beforeRequest: { req in
                try req.content.encode([
                    "name": "Session \(i + 2)",
                    "date": DateFormatter.yyyyMMdd.string(from: Date()),
                ])
            })
        }
        try app.test(.GET, "refinement_sessions/context") { res in
            let context = try res.content.decode(RefinementSessionController.Context.self)
            XCTAssertEqual(context.count, 11)
        }
    }

    func testRefinementSessionsGetOrderedByDateDesc() throws {
        let refinementSessions: [[String: String]] = (0..<10).map {
            [
                "name": "Session \($0)",
                "date": DateFormatter.yyyyMMdd
                    .string(from: Date().advanced(by: Double($0 * 60 * 1000))),
            ]
        }
        try refinementSessions.shuffled().forEach { refinementSession in
            try app.test(.POST, "refinement_sessions", beforeRequest: { req in
                try req.content.encode(refinementSession)
            })
        }
        try app.test(.GET, "refinement_sessions") { res in
            XCTAssertEqual(res.status, .ok)
            let result = try res.content.decode([RefinementSession].self)
            result.reversed().enumerated().forEach {
                let date = refinementSessions[$0]["date"]
                XCTAssertEqual(date, DateFormatter.yyyyMMdd.string(from: $1.date))
            }
        }
    }

    func testMaximumRefinementSessionsPost() throws {
        for i in 0..<RefinementSession.maximumAllowed {
            try app.test(.POST, "refinement_sessions", beforeRequest: { req in
                try req.content.encode([
                    "name": "Session \(i + 1)",
                    "date": DateFormatter.yyyyMMdd.string(from: Date()),
                ])
            })
        }

        try app.test(.GET, "refinement_sessions") { res in
            let refinementSessions = try res.content.decode([RefinementSession].self)
            XCTAssertEqual(refinementSessions.count, RefinementSession.maximumAllowed)
        }

        try app.test(.POST, "refinement_sessions", beforeRequest: { req in
            try req.content.encode([
                "name": "Session ... too much",
                "date": ISO8601DateFormatter().string(from: Date()),
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })
    }

    func testRefinementSessionsWithoutNamePost() throws {
        try app.test(.POST, "refinement_sessions", beforeRequest: { req in
            try req.content.encode([
                "date": ISO8601DateFormatter().string(from: Date()),
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })

        try app.test(.POST, "refinement_sessions", beforeRequest: { req in
            try req.content.encode([
                "name": "",
                "date": ISO8601DateFormatter().string(from: Date()),
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })
    }

    func testRefinementSessionDelete() throws {
        var id: UUID?
        try app.test(.POST, "refinement_sessions", beforeRequest: { req in
            try req.content.encode([
                "name": "Session to delete",
                "date": DateFormatter.yyyyMMdd.string(from: Date()),
            ])
        }, afterResponse: { res in
            let refinementSession = try res.content.decode(RefinementSession.self)
            XCTAssertNotNil(refinementSession.id)
            id = refinementSession.id
        })

        try app.test(.GET, "refinement_sessions") { res in
            let refinementSessions = try res.content.decode([RefinementSession].self)
            XCTAssertEqual(refinementSessions.count, 1)
        }

        let refinementSessionId = try XCTUnwrap(id)
        try app.test(.DELETE, "refinement_sessions/\(refinementSessionId)") { res in
            XCTAssertEqual(res.status, .ok)
        }

        try app.test(.GET, "refinement_sessions") { res in
            let refinementSessions = try res.content.decode([RefinementSession].self)
            XCTAssertEqual(refinementSessions.count, 0)
        }
    }
}
