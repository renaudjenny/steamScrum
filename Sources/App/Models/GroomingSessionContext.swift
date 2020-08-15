import Vapor

struct GroomingSessionContext: Content {
    static let maximumAllowed = 250

    var groomingSessionsCount: Int
    var maximumGroomingSessionsCount: Int
}
