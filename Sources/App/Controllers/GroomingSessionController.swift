import Fluent
import Vapor

struct GroomingSessionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let groomingSessions = routes.grouped("grooming_sessions")
        groomingSessions.get(use: index)
        groomingSessions.post(use: create)
        groomingSessions.group(":groomingSessionID") { groomingSession in
            groomingSession.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[GroomingSession]> {
        return GroomingSession.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<GroomingSession> {
        let groomingSession = try req.content.decode(GroomingSession.self)
        guard !groomingSession.name.isEmpty else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Grooming Session name cannot be empty"))
        }

        return GroomingSession.query(on: req.db).count().flatMap({
            guard $0 < GroomingSessionContext.maximumAllowed else {
                return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Too many data already provided."))
            }
            return groomingSession.save(on: req.db).map { groomingSession }
        })
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return GroomingSession.find(req.parameters.get("groomingSessionID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }

    func context(req: Request) throws -> EventLoopFuture<GroomingSessionContext> {
        return GroomingSession.query(on: req.db).count().map {
            let context = GroomingSessionContext(
                groomingSessionsCount: $0,
                maximumGroomingSessionsCount: GroomingSessionContext.maximumAllowed
            )
            return context
        }
    }
}
