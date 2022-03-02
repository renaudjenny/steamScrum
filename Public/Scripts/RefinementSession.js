import { preventFormSubmit, ids } from "./Common.js"

const { refinementSessionId } = ids()
const url = new URL(window.location.href)
const protocol = url.protocol === 'http:' ? 'ws' : 'wss'
const webSocketURL = `${protocol}://${url.host}/refinement_sessions/${refinementSessionId}/connect`

let webSocket
window.addEventListener("DOMContentLoaded", () => {
    webSocket = new WebSocket(webSocketURL)

    webSocket.addEventListener("open", (event) => {
        webSocket.send("connection-ready")
    })

    webSocket.addEventListener("message", (event) => {
        if (event.data[0] !== "{") {
            console.error("Error: Cannot parse this message: " + event.data)
            return
        }
        const data = JSON.parse(event.data)
        updateParticipants(data)
    })
})

const isWebSocketReady = () => webSocket?.readyState === WebSocket.OPEN
const send = (data) => webSocket.send(data)

const addVotingParticipant = () => {
    if (!isWebSocketReady()) {
        console.error("Cannot add voting participant, WebSocket isn't ready")
        return
    }
    const participantInput = document.getElementById("participant")
    if (participantInput.value === '') { return }

    const addParticipant = { addParticipant: participantInput.value }
    send(JSON.stringify(addParticipant))

    participantInput.value = ""
    participantInput.focus()
}

const updateParticipants = (data) => {
    const participants = document.getElementById("participants")

    const url = new URL(window.location.href)

    const items = data.participants.map((participant) => `<li>${participant}</li>`)
    participants.innerHTML = ["<ul>", ...items, "</ul>"].join("\n")
}

const createUserStory = () => {
    const name = document.getElementById('name').value
    const { refinementSessionId } = ids()
    fetch(`${refinementSessionId}/user_stories`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ name }),
    })
    .then(() => window.location.reload())
}

const removeUserStory = (userStoryId) =>
fetch(`${ids().refinementSessionId}/user_stories/${userStoryId}`, { method: 'DELETE' })
.then(() => window.location.reload())

document.querySelectorAll("button.remove-user-story-button")
.forEach(button => {
    const id = button.dataset.id
    button.addEventListener("click", () => removeUserStory(id))
})

preventFormSubmit('add-participant-form', addVotingParticipant)
preventFormSubmit('add-user-story-form', createUserStory);
