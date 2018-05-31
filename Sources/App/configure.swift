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
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())

    if let url = Environment.get("DATABASE_URL") {
        let psqlConfig = try PostgreSQLDatabaseConfig(url: url)
        services.register(psqlConfig)
    } else {
        let psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "postgres")
        services.register(psqlConfig)
    }

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: FlorianSentence.self, database: .psql)
    migrations.add(model: UserStory.self, database: .psql)
    migrations.add(model: Developer.self, database: .psql)
    migrations.add(model: GroomingSession.self, database: .psql)
    services.register(migrations)
}
