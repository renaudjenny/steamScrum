import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = try await Application.make(env)
do {
    try configure(app)
    try await app.execute()
} catch {
    try await app.asyncShutdown()
}
try await app.asyncShutdown()
