struct RefinementSessionData: Encodable {
    var title: String { refinementSession.name }
    let scriptFilename = "RefinementSession.js"
    let refinementSession: RefinementSession
    var maximumAllowed = UserStory.maximumAllowed
}
