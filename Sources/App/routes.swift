import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        GroomingSession.query(on: req.db).all().map(renderHomePage)
    }

    try app.register(collection: GroomingSessionController())
    app.get("groomingSessionsContext", use: GroomingSessionController().context(req:))
}

private func renderHomePage(with groomingSessions: [GroomingSession]) -> HTML {
    HTML(value: """
        <h1>Steam Scrum</h1>
        <p>This project changed a lot. It has been migrated to the last version of Vapor and will sooner be fully rendered in Swift! (See: <a href="https://github.com/swiftwasm/Tokamak">Tokamak project</a>)</p>
        <p>This is ugly for now as it's pure HTML without CSS</p>

        <form action="grooming_sessions" method="post">
        <div>
        <label for="name">Grooming Session name: </label>
        <input type="text" name="name" id="name" required>
        </div>
        <div>
        <label for="date">Date of the session: </label>
        <input type="date" name="date" id="date" required>
        </div>
        <div>
        <input type="submit" value="Submit!">
        </div>
        </form>

        <h2>Grooming Sessions</h2>
        \(groomingSessions.map({ groomingSession in
        """
        <div>
        <h3>\(groomingSession.name)<h3>
        <h4>\(groomingSession.date.description)<h4>
        </div>
        """
        }).joined()
        )
        """
    )
}
