struct HomepageData: Encodable {
    let title = "SteamScrum"
    let scriptFilename = "Homepage.js"
    let refinementSessions: [RefinementSession]
    let refinementSessionsMaximumAllowed: Int = RefinementSession.maximumAllowed
}
