import Fluent
import FluentSQL
import FluentPostgresDriver
import Foundation

// Grooming Session is an inappropriate name, hence, it has been migrated to Refinement Session
struct MoveGroomingSessionsToRefinementSessions: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        guard let sql = database as? PostgresDatabase
        else {
            // You certainly don't need to migrate if you're not using PostgreSQL
            return database.eventLoop.makeSucceededVoidFuture()
        }

        return sql.sql()
            .raw("ALTER TABLE grooming_sessions RENAME TO refinement_sessions")
            .run()
            .flatMap {
                database.schema("grooming_sessions").delete()
            }


        // Copy all the data from "grooming_sessions" to "refinement_sessions"
//        database.query(GroomingSession.self).all().flatMap { groomingSessions in
//            database.transaction { database -> EventLoopFuture<Void> in
//                groomingSessions.map {
//                    RefinementSession(
//                        id: $0.id,
//                        name: $0.name,
//                        date: $0.date
//                    )
//                    .save(on: database)
//                }
//                .flatten(on: database.eventLoop)
//                .flatMap {
//                    database.schema("grooming_sessions").delete()
//                }
//            }
//        }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        guard let sql = database as? PostgresDatabase
        else {
            // You certainly don't need to migrate if you're not using PostgreSQL
            return database.eventLoop.makeSucceededVoidFuture()
        }

        return sql.sql()
            .raw("ALTER TABLE refinement_sessions RENAME TO grooming_sessions")
            .run()
            .flatMap {
                database.schema("refinement_sessions").delete()
            }
    }
}
