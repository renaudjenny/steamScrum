import Foundation

struct UserStoryData: Encodable {
    struct Vote: Encodable {
        let id: String
        let date: Date
        let participants: String
        let average: String
    }

    let refinementSessionName: String
    let userStoryName: String
    let QRCodeSVG: String?
    let votes: [Vote]
}

extension UserStory {
    func viewData(QRCodeSVG: String?) -> UserStoryData {
        UserStoryData(
            refinementSessionName: refinementSession.name,
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
