import Vapor

extension UserStory {
    struct Vote: Content {
        var participants = Set<String>()
        var points: [String: Int] = [:]

        mutating func set(points: Int, for participant: String) {
            guard participants.contains(participant) else { return }
            self.points[participant] = points
        }

        var sum: Int { points.reduce(0, { $0 + $1.value }) }
    }
}
