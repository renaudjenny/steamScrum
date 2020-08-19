struct Homepage {
    let groomingSessionContext: GroomingSessionContext
    let groomingSessions: [GroomingSession]

    var render: HTML { HTML(value: """
        <html>
        <head>
        <meta charset="utf-8">
        \(script)
        <head>
        <body>
        \(title)
        \(groomingForm)
        \(groomingSessionsList)
        </body>
        </html>
        """
    )}

    var title: String { """
        <h1>Steam Scrum</h1>
        <p>This project changed a lot. It has been migrated to the last version of Vapor and will sooner be fully rendered in Swift! (See: <a href="https://github.com/swiftwasm/Tokamak">Tokamak project</a>)</p>
        <p>This is ugly for now as it's pure HTML without CSS</p>
        """
    }

    var groomingForm: String { """
        <h2>Add a Grooming Session</h2>
        <p>You can add grooming session to test the API</p>
        <form>
        <div>
        <label for="name">Grooming Session name: </label>
        <input type="text" name="name" id="name" required>
        </div>
        <div>
        <label for="date">Date of the session: </label>
        <input type="date" name="date" id="date" required>
        <button type="button" onclick="setGroomingSessionDateToNow()">Now</button>
        </div>
        <div>
        <button type="button" onclick="createGroomingSession()">
            Submit
        </button>
        </div>
        </form>
        """
    }

    var groomingSessionsList: String { """
        <h2>Grooming Sessions</h2>
        <p><strong>\(groomingSessionContext.groomingSessionsCount)/\(groomingSessionContext.maximumGroomingSessionsCount)</strong></p>
        \(groomingSessions.map({ groomingSession in
        """
        <div>
        <h3><a href="grooming_sessions/\(groomingSession.id!)">\(groomingSession.name)</a><h3>
        <button type="button" onClick='removeGroomingSession("\(groomingSession.id!)")'>❌</button>
        <h4>\(groomingSession.date.description)<h4>
        </div>
        """
        }).joined(separator: "<br />")
        )
        """
    }

    var script: String { """
        <script>
        const setGroomingSessionDateToNow = () => {
            const date = new Date()
            const iso8601Compatible = date.toISOString().replace(/\\.[0-9]{3}/, "")
            document.getElementById("date").setAttribute("value", iso8601Compatible)
        }
        const removeGroomingSession = (groomingSessionId) => fetch(`grooming_sessions/${groomingSessionId}`, { method: "DELETE" })
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
        </script>
        """
    }
}
