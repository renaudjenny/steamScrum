import Foundation

struct Homepage {
    let groomingSessionContext: GroomingSessionContext
    let groomingSessions: [GroomingSession]
    let formatDate: (Date) -> String

    var render: HTML { HTML(value: """
        <html>
        <head>
        <meta charset="utf-8">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/milligram/1.4.1/milligram.min.css" integrity="sha512-xiunq9hpKsIcz42zt0o2vCo34xV0j6Ny8hgEylN3XBglZDtTZ2nwnqF/Z/TTCc18sGdvCjbFInNd++6q3J0N6g==" crossorigin="anonymous"
        />
        \(script)
        <head>
        <body>
            <div class="container">
                \(title)
                \(groomingForm)
                \(groomingSessionsList)
            </div>
        </body>
        </html>
        """
    )}

    var title: String { """
        <div class="row">
            <h1>Steam Scrum</h1>
        </div>
        <div class="row">
            <p>This project changed a lot. It has been migrated to the last version of Vapor and will sooner be fully rendered in Swift! (See: <a href="https://github.com/swiftwasm/Tokamak">Tokamak project</a>)</p>
        </div>
        <div class="row">
            <p>This is using pure Javascript (without any external libraries), and <a href="https://milligram.io">Milligram</a> to give a little bit of style here and there.</p>
        </div>
        <div class="row">
            <p>The code is available here: <a href="https://github.com/renaudjenny/steamScrum">SteamScrum on GitHub</a></p>
        </div>
        """
    }

    var groomingForm: String { """
        <div class="row">
            <h2>Add a Grooming Session</h2>
        </div>
        <div class="row">
            <p>You can add grooming session to test the API</p>
        </div>
        <form>
            <fieldset>
                <label for="name">Grooming Session name: </label>
                <input type="text" name="name" id="name" required>
                <label for="date">Date of the session: </label>
                <div class="row">
                    <div class="column">
                        <input type="date" name="date" id="date" required>
                    </div>
                    <div class="column">
                        <button type="button" onclick="setGroomingSessionDateToNow()">Now</button>
                    </div>
                </div>
                <button type="button" onclick="createGroomingSession()">
                    Submit
                </button>
            </fieldset>
        </form>
        """
    }

    var groomingSessionsList: String { """
        <h2>Grooming Sessions</h2>
        <p><strong>\(groomingSessionContext.groomingSessionsCount)/\(groomingSessionContext.maximumGroomingSessionsCount)</strong></p>
        \(groomingSessions.map({ groomingSession in
        """
        <div class="row">
            <div class="column">
                <h3><a href="grooming_sessions/\(groomingSession.id!)">\(groomingSession.name)</a><h3>
            </div>
            <div class="column">
                <button type="button" onClick='removeGroomingSession("\(groomingSession.id!)")'>❌</button>
            </div>
        </div>
        <div class="row">
            <div class="column">
                <h4>\(formatDate(groomingSession.date))<h4>
            </div>
        </div>
        """
        }).joined(separator: "<br />")
        )
        """
    }

    var script: String { """
        <script>
        const setGroomingSessionDateToNow = () => {
            const formattedDate = new Date().toJSON().slice(0, 10)
            document.getElementById("date").setAttribute("value", formattedDate)
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
