import { preventFormSubmit } from "./Common.js";

const createRefinementSession = () => {
    const name = document.getElementById("name").value
    const date = document.getElementById("date").value
    fetch("refinement_sessions", {
        method: "POST",
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ name, date }),
    })
    .then(() => location.reload())
}

const removeRefinementSession = (refinementSessionId) =>
fetch(`refinement_sessions/${refinementSessionId}`, { method: "DELETE" })
.then(() => location.reload())

document.querySelectorAll("button.remove-refinement-session-button")
.forEach(button => {
    const id = button.dataset.id
    button.addEventListener("click", () => removeRefinementSession(id))
})

const setRefinementSessionDateToNow = () => {
    const formattedDate = new Date().toJSON().slice(0, 10)
    document.getElementById("date").setAttribute("value", formattedDate)
}

document.getElementById("refinement-session-date-now-button")
.addEventListener("click", setRefinementSessionDateToNow)

preventFormSubmit("add-refinement-session-form", createRefinementSession)
