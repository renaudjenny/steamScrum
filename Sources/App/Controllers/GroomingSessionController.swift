import Fluent
import Vapor

struct GroomingSessionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let groomingSessions = routes.grouped("grooming_sessions")
        groomingSessions.get(use: index)
        groomingSessions.post(use: create)
        groomingSessions.group(":groomingSessionID") { groomingSession in
            groomingSession.get(use: get)
            groomingSession.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[GroomingSession]> {
        return GroomingSession.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<GroomingSession> {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
        let groomingSession = try req.content.decode(GroomingSession.self, using: jsonDecoder)
        print(groomingSession.date)
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

    func get(req: Request) throws -> EventLoopFuture<HTML> {
        guard
        let groomingSessionIdString = req.parameters.get("groomingSessionID"),
        let groomingSessionId = UUID(uuidString: groomingSessionIdString)
        else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        return GroomingSession.query(on: req.db)
            .filter(\.$id == groomingSessionId)
            .with(\.$userStories)
            .first()
            .unwrap(or: Abort(.notFound))
            .map { GroomingSessionView(groomingSession: $0).render }
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

private extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
