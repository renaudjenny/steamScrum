import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { (req: Request) in
        HTML(value: "<h1>Grooming Sessions</h1>")
    }

    try app.register(collection: GroomingSessionController())
}
