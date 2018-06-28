import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    try services.register(FluentPostgreSQLProvider())

    var databases = DatabasesConfig()
    let databaseConfig: PostgreSQLDatabaseConfig?

    if let url = Environment.get("DATABASE_URL") {
        databaseConfig = try PostgreSQLDatabaseConfig(url: url)
    } else {
        databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "postgres")
    }

    let database = PostgreSQLDatabase(config: databaseConfig!)
    databases.add(database: database, as: .psql)
    services.register(databases)

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    services.register(ReactMiddleware.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(ReactMiddleware.self)
    services.register(middlewares)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: FlorianSentence.self, database: .psql)
    migrations.add(model: UserStory.self, database: .psql)
    migrations.add(model: UserStory.StoryPoint.self, database: .psql)
    migrations.add(model: Developer.self, database: .psql)
    migrations.add(model: GroomingSession.self, database: .psql)
    services.register(migrations)
}
