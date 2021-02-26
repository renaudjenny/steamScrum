export const preventFormSubmit = (id, submitFunction) => {
    window.addEventListener("DOMContentLoaded", () => {
        const form = document.getElementById(id)
        if (form == null) { return }

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
