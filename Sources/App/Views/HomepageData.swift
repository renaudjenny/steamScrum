struct HomepageData: Codable {
    let refinementSessions: [RefinementSession]
    var refinementSessionsMaximumAllowed: Int = RefinementSession.maximumAllowed
}
