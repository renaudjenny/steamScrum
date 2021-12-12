import {
    preventFormSubmit,
    ids,
    updateParticipantTable,
} from './Common.js'
import { UserStoryWebSocket } from './UserStoryWebSocket.js'

const { isWebSocketReady, send } = UserStoryWebSocket((data) => {
    updateParticipantsButtons(data)
    updateVoteStatus(data)
    updatePointsButton(data)
})

const saveVote = () => {
    fetch(`${ids().userStoryId}/vote`, { method: "POST" })
    .then(() => location.reload())
}
document.getElementById("save-button").addEventListener("click", saveVote)

const removeVote = (voteId) => {
    fetch(`${ids().userStoryId}/vote/${voteId}`, { method: "DELETE" })
    .then(() => location.reload())
}
document.querySelectorAll("button.remove-user-story-vote-button")
.forEach(button => {
    const id = button.dataset.id
    button.addEventListener("click", () => removeVote(id))
})

const updateParticipantsButtons = (data) => {
    const participantsButtons = document.getElementById("participants-buttons")

    const url = new URL(window.location.href)
    participantsButtons.innerHTML = data.participants.reduce((result, participant) => {
        return result + `<button
        class="button button-outline"
        onClick="window.location.href = '${url}/vote/${participant}'"
        >
        ${participant}
        </button>
        `
    }, '')
}

const updateVoteStatus = (data) => {
    updateParticipantTable(data)
    const saveButton = document.getElementById("save-button")
    const saveButtonHelp = document.getElementById("save-button-help")

    const isVoteFinished = data.avg != null
    if (isVoteFinished) {
        saveButton.removeAttribute("disabled")
        saveButtonHelp.hidden = true
    } else {
        saveButton.setAttribute("disabled", "true")
        saveButtonHelp.hidden = false
    }
}

const updatePointsButton = (data) => {
    const pointsButtons = document.getElementsByName("points-button")

    const url = new URL(window.location.href)
    const paths = url.pathname.split("/")
    const participant = paths.pop()

    const selectedPoints = data.points[participant]
    if (selectedPoints == null) { return }

    pointsButtons.forEach(button => {
        const points = parseInt(button.getAttribute("data-points"))
        if (points == null) { return }
        if (points === selectedPoints) {
            button.className = "button"
        } else {
            button.className = "button button-outline"
        }
    })
}
