struct UserStoryVoteData: Encodable {
    var title: String { userStoryName }
    let scriptFilename = "UserStoryVote.js"
    let userStoryName: String
    let refinementSessionName: String
    let participantName: String
}
