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

const getGroomingSessionId = () => {
    const url = new URL(window.location.href)
    return url.pathname.split('/').pop()
}

const createUserStory = () => {
    const name = document.getElementById('name').value
    fetch(`${getGroomingSessionId()}/user_stories`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ name }),
    })
    .then(() => window.location.reload())
}

const removeUserStory = (userStoryId) =>
    fetch(`${getGroomingSessionId()}/user_stories/${userStoryId}`, { method: 'DELETE' })
        .then(() => window.location.reload())
