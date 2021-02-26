import { preventFormSubmit, ids } from "./Common.js"

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

preventFormSubmit('add-user-story-form', createUserStory);
