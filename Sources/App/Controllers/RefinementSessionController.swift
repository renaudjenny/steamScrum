import Fluent
import Vapor
import HTMLKit

struct RefinementSessionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let refinementSessions = routes.grouped("refinement_sessions")
        refinementSessions.get(use: index)
        refinementSessions.post(use: create)
        refinementSessions.group(":refinementSessionID") { refinementSession in
            refinementSession.get(use: get)
            refinementSession.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[RefinementSession]> {
        RefinementSession.query(on: req.db).sort(\.$date, .descending).all()
    }

    func create(req: Request) throws -> EventLoopFuture<RefinementSession> {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
        let refinementSession = try req.content.decode(RefinementSession.self, using: jsonDecoder)
        guard !refinementSession.name.isEmpty else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Refinement Session name cannot be empty"))
        }

        return RefinementSession.query(on: req.db).count().flatMap({
            guard $0 < RefinementSessionContext.maximumAllowed else {
                return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Too many data already provided."))
            }
            return refinementSession.save(on: req.db).map { refinementSession }
        })
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        RefinementSession.find(req.parameters.get("refinementSessionID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }

    func get(req: Request) throws -> EventLoopFuture<View> {
        guard
        let refinementSessionIdString = req.parameters.get("refinementSessionID"),
        let refinementSessionId = UUID(uuidString: refinementSessionIdString)
        else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return RefinementSession.query(on: req.db)
            .filter(\.$id == refinementSessionId)
            .with(\.$userStories)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap {
                RefinementSessionTemplate().render(with: RefinementSessionData(refinementSession: $0), for: req)
            }
    }

    func context(req: Request) throws -> EventLoopFuture<RefinementSessionContext> {
        RefinementSession.query(on: req.db).count().map {
            let context = RefinementSessionContext(
                refinementSessionsCount: $0,
                maximumRefinementSessionsCount: RefinementSessionContext.maximumAllowed
            )
            return context
        }
    }
}
