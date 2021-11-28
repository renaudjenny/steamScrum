import Fluent
import FluentPostgresDriver
#if canImport(FluentSQLiteDriver)
import FluentSQLiteDriver
#endif
import Vapor
import HTMLKitVaporProvider
import Leaf

// configures your application
public func configure(_ app: Application) throws {
    // Serves files from `Public/` directory
    let fileMiddleware = FileMiddleware(
        publicDirectory: app.directory.publicDirectory
    )
    app.middleware.use(fileMiddleware)

    if app.environment == .testing {
        #if canImport(FluentSQLiteDriver)
        app.databases.use(.sqlite(.memory), as: .sqlite)
        #endif
    } else if let databaseURL = Environment.get("DATABASE_URL"),
              var postgresConfig = PostgresConfiguration(url: databaseURL) {
        postgresConfig.tlsConfiguration = .makeClientConfiguration()
        postgresConfig.tlsConfiguration?.certificateVerification = .none
        app.databases.use(.postgres(
            configuration: postgresConfig
        ), as: .psql)
    } else {
        app.databases.use(.postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database"
        ), as: .psql)
    }

    app.views.use(.leaf)

    app.migrations.add(CreateRefinementSession())
    app.migrations.add(CreateUserStory())
    app.migrations.add(CreateUserStoryVote())

    // register routes
    try routes(app)
}

extension Environment {
    var host: String {
        switch self {
        case .development, .testing:
            return "http://localhost:8080"
        default:
            return "https://steam-scrum.herokuapp.com"
        }
    }
}
