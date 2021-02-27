export const preventFormSubmit = (id, submitFunction) => {
    window.addEventListener("DOMContentLoaded", () => {
        const form = document.getElementById(id)
        form.addEventListener("submit", (event) => {
            event.preventDefault()
            submitFunction()
        })
    })
}

export const ids = () => {
    const url = new URL(window.location.href)
    const paths = url.pathname.split("/")
    const refinementSessionId = paths[paths.indexOf("refinement_sessions") + 1]
    const userStoryId = paths[paths.indexOf("user_stories") + 1]

    return {
        refinementSessionId,
        userStoryId,
    }
}

export const updateParticipantTable = (data) => {
    const participantsTable = document.getElementById("participants-table")

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
}
