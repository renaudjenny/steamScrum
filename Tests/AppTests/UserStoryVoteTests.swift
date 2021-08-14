@testable import App
import XCTVapor

final class UserStoryVoteTests: XCTestCase {
    private let app = Application(.testing)
    private var refinementSession: RefinementSession?
    private var userStory: UserStory?

    override func setUpWithError() throws {
        try super.setUpWithError()
        try configure(app)
        try app.autoMigrate().wait()

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

    func testVoteGet() throws {
        // Check first that the store is empty
        XCTAssertEqual(app.userStoriesVotes.count, 0)

        try app.test(.GET, "refinement_sessions/\(try refinementSessionId())/user_stories/\(try userStoryId())/vote") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(app.userStoriesVotes.count, 1)
        }
    }

    func testVoteView() throws {
        // Mock that a participant has already been added to the store
        try app.userStoriesVotes[try userStoryId()] = UserStoryVote(
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

        try app.userStoriesVotes[try userStoryId()] = UserStoryVote(
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
        try app.userStoriesVotes[try userStoryId()] = UserStoryVote(
            userStory: try XCTUnwrap(userStory),
            participants: ["Mario", "Luigi"],
            points: ["Mario": 3, "Luigi": 5]
        )

        try app.test(.POST, "refinement_sessions/\(try refinementSessionId())/user_stories/\(try userStoryId())/vote") { res in
            XCTAssertEqual(res.status, .ok)
            let userStoryVote = try XCTUnwrap(res.content.decode(UserStoryVote.self))
            XCTAssert(userStoryVote.participants.contains("Mario"), "Mario should be a participant")
            XCTAssert(userStoryVote.participants.contains("Luigi"), "Luigi should be a participant")
            XCTAssertEqual(userStoryVote.points["Mario"], 3, "Mario points should be 3")
            XCTAssertEqual(userStoryVote.points["Luigi"], 5, "Mario points should be 5")
        }
    }

    func testSaveMoreThanMaxAmountOfVotePerUserStory() throws {
        // You can actually persist the same Vote multiple time
        try (0..<UserStoryVote.maximumAllowedPerUserStory).forEach { i in
            // Mock that a participant has already been added to the store
            try app.userStoriesVotes[try userStoryId()] = UserStoryVote(
                userStory: try XCTUnwrap(userStory),
                participants: ["Mario \(i)"]
            )

            try app.test(.POST, "refinement_sessions/\(try refinementSessionId())/user_stories/\(try userStoryId())/vote") { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertNotNil(try res.content.decode(UserStoryVote.self))
            }
        }

        let count = try numberOfVotes(for: try userStoryId())
        XCTAssertEqual(count, UserStoryVote.maximumAllowedPerUserStory)

        try app.userStoriesVotes[try userStoryId()] = UserStoryVote(
            userStory: try XCTUnwrap(userStory),
            participants: ["Mario too much"]
        )
        try app.test(.POST, "refinement_sessions/\(try refinementSessionId())/user_stories/\(try userStoryId())/vote") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testDeleteUserStoryVote() throws {
        try app.userStoriesVotes[try userStoryId()] = UserStoryVote(
            userStory: try XCTUnwrap(userStory)
        )

        var id: UUID?
        try app.test(.POST, "refinement_sessions/\(try refinementSessionId())/user_stories/\(try userStoryId())/vote") { res in
            XCTAssertEqual(res.status, .ok)
            let vote = try res.content.decode(UserStoryVote.self)
            id = vote.id
        }

        var count = try numberOfVotes(for: try userStoryId())
        XCTAssertEqual(count, 1)

        let voteId = try XCTUnwrap(id)
        try app.test(.DELETE, "refinement_sessions/\(try refinementSessionId())/user_stories/\(try userStoryId())/vote/\(voteId)") { res in
            XCTAssertEqual(res.status, .ok)
        }

        count = try numberOfVotes(for: try userStoryId())
        XCTAssertEqual(count, 0)
    }

    private func numberOfVotes(for userStoryId: UUID) throws -> Int {
        // There is no possibility to GET the UserStory to list votes yet,
        // there is only a View, which is hard to test, so we will use a manual DB request
        // to check if the count of votes for this US is the expected one
        return try UserStoryVote.query(on: app.db)
            // For some reason it's not compiling while I try to filter here. It doesn't really matter for this test tho
            // .filter(\.$userStory.$id == usId)
            .count()
            .wait()
    }
}
