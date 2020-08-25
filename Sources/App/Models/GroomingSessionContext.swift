import Vapor

// TODO: I'm questioning if we need "SomethingContext" struct
// it could rather be part of GroomingSession extension or something like that.
// We have no usage now to provide the Context.
struct GroomingSessionContext: Content {
    static let maximumAllowed = 250

    var groomingSessionsCount: Int
    var maximumGroomingSessionsCount: Int
}
