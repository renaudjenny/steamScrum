import Fluent
import Vapor

final class UserStoryVote: Content, Model {
    static let schema = "user_story_votes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "participants")
    var participants: [String]

    @Field(key: "points")
    var points: [String: Int]

    @Field(key: "date")
    var date: Date

    @Parent(key: "user_story_id")
    var userStory: UserStory

    init() { }

    init(
        userStory: UserStory,
        participants: [String] = [],
        points: [String: Int] = [:],
        date: Date = Date()
    ) throws {
        self.$userStory.id = try userStory.requireID()
        self.participants = participants
        self.points = points
        self.date = date
    }

    func add(participant: String) {
        guard participants.count < 50,
              !participants.contains(participant)
        else { return }
        participants.append(participant)
    }

    func set(points: Int, for participant: String) {
        guard participants.contains(participant)
        else { return }
        self.points[participant] = points
    }

    var sum: Int? {
        guard points.count == participants.count,
              points.count > 0
        else { return nil }
        return points.reduce(0, { $0 + $1.value })
    }
    var avg: Double? {
        guard let sum = sum else { return nil }
        return Double(sum)/Double(participants.count)
    }
}

extension UserStoryVote {
    static let maximumAllowedPerUserStory = 5
}

extension UserStoryVote {
    struct Encoded: Encodable {
        var participants: [String]
        var points: [String: Int]
        var sum: Int?
        var avg: Double?
        var date: Date
    }

    var encoded: Encoded {
        Encoded(participants: participants, points: points, sum: sum, avg: avg, date: date)
    }
}
