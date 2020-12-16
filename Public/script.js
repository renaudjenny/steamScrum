const setGroomingSessionDateToNow = () => {
    const formattedDate = new Date().toJSON().slice(0, 10)
    document.getElementById("date").setAttribute("value", formattedDate)
}

const removeGroomingSession = (groomingSessionId) =>
    fetch(`grooming_sessions/${groomingSessionId}`, { method: "DELETE" })
        .then(() => location.reload())

const createGroomingSession = () => {
    const name = document.getElementById("name").value
    const date = document.getElementById("date").value
    fetch("grooming_sessions", {
        method: "POST",
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ name, date }),
    })
    .then(() => location.reload())
}

const ids = () => {
    const url = new URL(window.location.href)
    const paths = url.pathname.split("/")
    const groomingSessionId = paths[paths.indexOf("grooming_sessions") + 1]
    const userStoryId = paths[paths.indexOf("user_stories") + 1]

    return {
        groomingSessionId,
        userStoryId,
    }
}

const createUserStory = () => {
    const name = document.getElementById('name').value
    const { groomingSessionId } = ids()
    fetch(`${groomingSessionId}/user_stories`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ name }),
    })
    .then(() => window.location.reload())
}

const removeUserStory = (userStoryId) =>
    fetch(`${ids().groomingSessionId}/user_stories/${userStoryId}`, { method: 'DELETE' })
        .then(() => window.location.reload())

// TODO: Extract this part into its own file?
let webSocket = null
const isWebSocketReady = () => {
    return webSocket != null &&
        webSocket.readyState === WebSocket.CLOSED &&
        webSocket.readyState === WebSocket.CLOSING
}

const connectToTheUserStoryVoteWebSocket = () => {
    const { groomingSessionId, userStoryId } = ids()
    const url = new URL(window.location.href)
    const protocol = url.protocol === 'http:' ? 'ws' : 'wss'
    const webSocketURL = `${protocol}://${url.host}/grooming_sessions/${groomingSessionId}/user_stories/${userStoryId}/vote`

    window.addEventListener("DOMContentLoaded", () => {
        webSocket = new WebSocket(webSocketURL);

        webSocket.addEventListener("open", (event) => {
            webSocket.send("connection-ready");
        })

        webSocket.addEventListener("message", (event) => {
            if (event.data[0] !== "{") {
                console.error("Error: Cannot parse this message: " + event.data)
                return
            }
            const data = JSON.parse(event.data)

            // TODO: Debug code, remove it at some point
            document.getElementById("vote-session-data").innerHTML = "<pre>"
              + JSON.stringify(data, null, 2)
              + "</pre>"

            updateParticipantsButtonsIfNeeded(data, url)
            updateVoteStatusIfNeeded(data)

            updatePointsButtonIfNeeded(data)
        })
    })
}

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

const setVote = (participant, points) => {
    if (!isWebSocketReady) {
        console.error("Cannot vote, WebSocket isn't ready")
        return
    }

    const vote = { vote: { participant, points }}
    webSocket.send(JSON.stringify(vote))
}

const addVotingParticipant = () => {
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
    alert("Sorry the save vote feature is still work in progress. It will be implemented soon!")
}

const preventFormSubmit = (id) => {
    window.addEventListener("DOMContentLoaded", () => {
        const form = document.getElementById(id)
        if (form == null) { return }

        form.addEventListener("submit", (event) => {
            event.preventDefault()
            switch (id) {
                case "add-grooming-session-form":
                    createGroomingSession()
                    break
                case "add-user-story-form":
                    createUserStory()
                    break
                case "add-participant-form":
                    addVotingParticipant()
                    break
            }
        })
    })
}
