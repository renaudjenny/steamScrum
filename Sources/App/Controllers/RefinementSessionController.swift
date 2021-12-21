import Fluent
import Vapor

struct RefinementSessionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let refinementSessions = routes.grouped("refinement_sessions")
        refinementSessions.get(use: index)
        refinementSessions.post(use: create)
        refinementSessions.group(":refinementSessionID") { refinementSession in
            refinementSession.get(use: get)
            refinementSession.delete(use: delete)
            refinementSession.webSocket("connect", onUpgrade: upgrade)
        }
        refinementSessions.get("context", use: context)
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
            guard $0 < RefinementSession.maximumAllowed else {
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
                let refinementSessionData = RefinementSessionData(refinementSession: $0)
                return req.view.render("refinementSession", refinementSessionData)
            }
    }

    func context(req: Request) throws -> EventLoopFuture<Context> {
        RefinementSession.query(on: req.db).count().map {
            Context(
                count: $0,
                maximum: RefinementSession.maximumAllowed
            )
        }
    }

    private func upgrade(req: Request, webSocket: WebSocket) {
        guard let refinementSessionIdString = req.parameters.get("refinementSessionID"),
              let refinementSessionId = UUID(uuidString: refinementSessionIdString)
        else {
            webSocket.send("Bad request")
            _ = webSocket.close()
            return
        }

        let webSocketId = UUID()

        webSocket.onText { onMessageReceived(
            webSocketId: webSocketId,
            refinementSessionId: refinementSessionId,
            webSocket: $0,
            text: $1,
            application: req.application
        ) }

        webSocket.onClose.whenComplete { _ in
            req.application.updateCallbacks.removeValue(forKey: webSocketId)
        }
    }

    private func onMessageReceived(
        webSocketId: UUID,
        refinementSessionId: UUID,
        webSocket: WebSocket,
        text: String,
        application: Application
    ) {
        if text == "connection-ready" {
            onConnectionReady(
                webSocketId: webSocketId,
                refinementSessionId: refinementSessionId,
                webSocket: webSocket,
                application: application
            )
        } else if text.contains("addParticipant") {
            onAddParticipant(
                webSocketId: webSocketId,
                refinementSessionId: refinementSessionId,
                webSocket: webSocket,
                text: text,
                application: application
            )
        }
    }

    private func onConnectionReady(
        webSocketId: UUID,
        refinementSessionId: UUID,
        webSocket: WebSocket,
        application: Application
    ) {
        struct Participants: Encodable {
            var participants: [String]
        }

        application.updateCallbacks[webSocketId] = {
            let message: String
            do {
                let participants = application.refinementSessionParticipants[refinementSessionId]
                ?? []
                let data = try JSONEncoder().encode(Participants(participants: participants))
                message = String(data: data, encoding: .utf8) ?? "Error: Cannot convert data to UTF-8 format"
            } catch {
                message = "Error: \(error)"
            }
            webSocket.send(message)
        }
        application.updateWebSockets()
    }

    private func onAddParticipant(
        webSocketId: UUID,
        refinementSessionId: UUID,
        webSocket: WebSocket,
        text: String,
        application: Application
    ) {
        struct AddParticipant: Decodable {
            var addParticipant: String
        }

        do {
            guard let data = text.data(using: .utf8) else {
                webSocket.send("Error: Cannot convert '\(text)' to UTF-8 Data")
                return
            }
            let addParticipant = try JSONDecoder().decode(AddParticipant.self, from: data)

            if application.refinementSessionParticipants[refinementSessionId] == nil {
                application.refinementSessionParticipants[refinementSessionId] = []
            }

            application.refinementSessionParticipants[refinementSessionId]?.append(
                addParticipant.addParticipant
            )
        } catch {
            webSocket.send("Error: \(error)")
            return
        }
    }
}

extension RefinementSessionController {
    struct Context: Content {
        var count: Int
        var maximum: Int
    }
}
