import Foundation

struct UserStoryData: Encodable {
    struct Vote: Encodable {
        let id: String
        let date: Date
        let participants: String
        let average: String
    }

    var title: String { userStoryName }
    let scriptFilename = "UserStory.js"
    let refinementSessionName: String
    let refinementSessionURL: String
    let userStoryName: String
    let QRCodeSVG: String?
    let votes: [Vote]
}

extension UserStory {
    func viewData(refinementSessionURL: String, QRCodeSVG: String?) -> UserStoryData {
        UserStoryData(
            refinementSessionName: refinementSession.name,
            refinementSessionURL: refinementSessionURL,
            userStoryName: name,
            QRCodeSVG: QRCodeSVG,
            votes: votes.map { vote in
                UserStoryData.Vote(
                    id: vote.id?.uuidString ?? "",
                    date: vote.date,
                    participants: vote.participants.joined(separator: ", "),
                    average: vote.avg.map { String(format: "%.2f", $0) } ?? ""
                )
            }
        )
    }
}
