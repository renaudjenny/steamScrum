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
