import { preventFormSubmit, ids } from './Common.js'

let webSocket = null

const connectToTheUserStoryVoteWebSocket = () => {
    const { refinementSessionId, userStoryId } = ids()
    const url = new URL(window.location.href)
    const protocol = url.protocol === 'http:' ? 'ws' : 'wss'
    const webSocketURL = `${protocol}://${url.host}/refinement_sessions/${refinementSessionId}/user_stories/${userStoryId}/vote/connect`

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

            updateParticipantsButtonsIfNeeded(data, url)
            updateVoteStatusIfNeeded(data)

            updatePointsButtonIfNeeded(data)
        })
    })
}
connectToTheUserStoryVoteWebSocket()

const addVotingParticipant = () => {
    const isWebSocketReady = webSocket?.readyState === WebSocket.OPEN
    if (!isWebSocketReady) {
        console.error("Cannot add voting participant, WebSocket isn't ready")
        return
    }
    const participantInput = document.getElementById("participant")
    if (participantInput.value === '') { return }

    const addVotingParticipant = { addVotingParticipant: participantInput.value }
    webSocket.send(JSON.stringify(addVotingParticipant))

    participantInput.value = ""
    participantInput.focus()
}

const saveVote = () => {
    alert("Sorry the save vote feature is still work in progress. It will be implemented soon!\n"
          + "See https://github.com/renaudjenny/steamScrum/issues/27")
}
document.getElementById("save-button").addEventListener("click", saveVote)

const updateParticipantsButtonsIfNeeded = (data, url) => {
    const participantsButtons = document.getElementById("participants-buttons")
    if (participantsButtons == null) { return }

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

const updateVoteStatusIfNeeded = (data) => {
    const participantsTable = document.getElementById("participants-table")
    if (participantsTable == null) { return }

    const isVoteFinished = data.avg != null

    participantsTable.innerHTML = data.participants.reduce((result, participant) => {
        const points = data.points[participant]
        const hasVoted = points != null
        return result + `<tr>
        <td>${participant}</td>
        <td>${hasVoted ? "✅" : "❓"}</td>
        <td>${isVoteFinished ? points : "👀"}</td>
        </tr>`
    }, '')

    if (isVoteFinished) {
        participantsTable.innerHTML += `<tr>
        <td><b>Average points</b></td>
        <td></td>
        <td><b>${data.avg.toFixed(2).replace(/[.,]00$/, "")}</b></td>
        </tr>`
    }

    const saveButton = document.getElementById("save-button")
    const saveButtonHelp = document.getElementById("save-button-help")
    if (saveButton == null || saveButtonHelp == null) { return }
    if (isVoteFinished) {
        saveButton.removeAttribute("disabled")
        saveButtonHelp.removeAttribute("hidden")
    } else {
        saveButton.setAttribute("disabled", "true")
        saveButtonHelp.setAttribute("hidden", "true")
    }
}

const updatePointsButtonIfNeeded = (data) => {
    const pointsButtons = document.getElementsByName("points-button")
    if (pointsButtons == null) { return }

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
