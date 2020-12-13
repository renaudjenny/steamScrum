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

const addVotingParticipant = () => {
    const { userStoryId } = ids()
    const participant = document.getElementById("participant").value
    fetch(`${userStoryId}/vote`, {
        method: "POST",
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ participant }),
    })
}

const vote = (participant) => {
//    const { userStoryId } = ids()
//    const points = parseInt(document.getElementById("renaud-vote").value)
//    fetch(`${userStoryId}/vote/Renaud`, {
//    method: "POST",
//    headers: {
//        'Content-Type': 'application/json',
//    },
//    body: JSON.stringify({ participant: "Renaud", points: points }),
//    })
    console.log(`should redirect to vote for ${participant}`)
}

const connectToTheUserStoryVoteWebSocket = () => {
    const { groomingSessionId, userStoryId } = ids()
    const url = new URL(window.location.href)
    const webSocketURL = `ws://${url.host}/grooming_sessions/${groomingSessionId}/user_stories/${userStoryId}/vote`

    window.addEventListener("DOMContentLoaded", () => {
        const socket = new WebSocket(webSocketURL);

        socket.addEventListener("open", (event) => {
            socket.send("connection-ready");
        })

        socket.addEventListener("message", (event) => {
            if (event.data[0] === "{") {
                const data = JSON.parse(event.data)

                // TODO: Debug code, remove it at some point
                document.getElementById("vote-session-data").innerHTML = "<pre>"
                  + JSON.stringify(data, null, 2)
                  + "</pre>"

                if (document.getElementById("participants-buttons") != null) {
                    document.getElementById("participants-buttons").innerHTML = data.participants.reduce((result, participant) => {
                        return result + `<button
                            class="button button-outline"
                            onClick="window.location.href = '${url}/vote/${participant}'"
                        >
                            ${participant}
                        </button>
                        `
                    }, '')
                }

                const isVoteFinished = Object.keys(data.points).length === data.participants.length
                document.getElementById("participants-table").innerHTML = data.participants.reduce((result, participant) => {
                    const points = data.points[participant]
                    const hasVoted = points != null
                    return result + `<tr>
                        <td>${participant}</td>
                        <td>${hasVoted ? "✅" : "❓"}</td>
                        <td>${isVoteFinished ? points : "👀"}</td>
                    </tr>`
                }, '')
            }
        })
    })
}
