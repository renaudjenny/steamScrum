import HTMLKit

struct UserStoryVoteData: Encodable {
    let userStoryName: String
    let refinementSessionName: String
    let participantName: String
}
