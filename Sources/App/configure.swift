import Fluent
import FluentPostgresDriver
// Useful to test locally. However, it won't work on Heroku as SQLite driver is not available
//import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    if app.environment == .testing {
        // Useful to test locally. However, it won't work on Heroku as SQLite driver is not available
        // Uncomment the import and the line bellow or it will crash at runtime
        // app.databases.use(.sqlite(.memory), as: .sqlite)
    } else if let url = Environment.get("DATABASE_URL") {
        app.databases.use(try .postgres(url: url), as: .psql)
    } else {
        app.databases.use(.postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database"
        ), as: .psql)
    }

    app.migrations.add(CreateGroomingSession())
    app.migrations.add(CreateUserStory())

    // register routes
    try routes(app)
}
