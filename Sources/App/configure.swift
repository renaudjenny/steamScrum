import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let databaseConfiguration: DatabaseConfigurationFactory
    if let url = Environment.get("DATABASE_URL") {
        databaseConfiguration = try .postgres(url: url)
    } else {
        databaseConfiguration = .postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database"
        )
    }

    app.databases.use(databaseConfiguration, as: .psql)

    app.migrations.add(CreateGroomingSession())

    // register routes
    try routes(app)
}
