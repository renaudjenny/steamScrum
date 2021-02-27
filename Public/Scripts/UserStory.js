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

const addVotingParticipant = () => {
    if (!isWebSocketReady()) {
        console.error("Cannot add voting participant, WebSocket isn't ready")
        return
    }
    const participantInput = document.getElementById("participant")
    if (participantInput.value === '') { return }

    const addVotingParticipant = { addVotingParticipant: participantInput.value }
    send(JSON.stringify(addVotingParticipant))

    participantInput.value = ""
    participantInput.focus()
}

const saveVote = () => {
    alert("Sorry the save vote feature is still work in progress. It will be implemented soon!\n"
          + "See https://github.com/renaudjenny/steamScrum/issues/27")
}
document.getElementById("save-button").addEventListener("click", saveVote)

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
        saveButtonHelp.removeAttribute("hidden")
    } else {
        saveButton.setAttribute("disabled", "true")
        saveButtonHelp.setAttribute("hidden", "true")
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

preventFormSubmit('add-participant-form', addVotingParticipant)
