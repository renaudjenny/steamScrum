import { updateParticipantTable } from "./Common.js"
import { UserStoryWebSocket } from "./UserStoryWebSocket.js"

const url = new URL(window.location.href)
const paths = url.pathname.split("/")
const participant = paths[paths.indexOf("vote") + 1]

const { isWebSocketReady, send } = UserStoryWebSocket((data) => {
    updateParticipantTable(data)
})

document.querySelectorAll("button.vote-button").forEach(button => {
    button.addEventListener("click", () => setVote(participant, button.dataset.points))
})

const setVote = (participant, points) => {
    if (!isWebSocketReady()) {
        console.error("Cannot vote, WebSocket isn't ready")
        return
    }

    const vote = { vote: { participant, points: parseInt(points) }}
    send(JSON.stringify(vote))
}
