import Vapor

extension UserStory {
    struct Vote: Content {
        var participants: [String] = []
        var points: [String: Int] = [:]

        mutating func add(participant: String) {
            guard participants.count < 50,
                  !participants.contains(participant)
            else { return }
            participants.append(participant)
        }

        mutating func set(points: Int, for participant: String) {
            guard participants.contains(participant) else { return }
            self.points[participant] = points
        }

        var sum: Int { points.reduce(0, { $0 + $1.value }) }
        var avg: Double { Double(sum)/Double(participants.count) }
    }
}

extension UserStory.Vote {
    struct Encoded: Encodable {
        var participants: [String]
        var points: [String: Int]
        var sum: Int
        var avg: Double
    }
    var encoded: Encoded { Encoded(
        participants: participants,
        points: points,
        sum: sum,
        avg: avg
    )}
}
