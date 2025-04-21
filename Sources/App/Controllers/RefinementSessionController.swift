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

    func index(req: Request) async throws -> [RefinementSession] {
        try await RefinementSession.query(on: req.db).sort(\.$date, .descending).all()
    }

    func create(req: Request) async throws -> RefinementSession {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
        let refinementSession = try req.content.decode(RefinementSession.self, using: jsonDecoder)
        guard !refinementSession.name.isEmpty else {
            throw Abort(.badRequest, reason: "Refinement Session name cannot be empty")
        }

        let count = try await RefinementSession.query(on: req.db).count()
        guard count < RefinementSession.maximumAllowed else {
            throw Abort(.badRequest, reason: "Too many data already provided.")
        }
        try await refinementSession.save(on: req.db)
        return  refinementSession
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let refinementSession = try await RefinementSession
            .find(req.parameters.get("refinementSessionID"), on: req.db)
        else { throw Abort(.notFound) }
        try await refinementSession.delete(on: req.db)
        return .ok
    }

    func get(req: Request) async throws -> View {
        guard
        let refinementSessionIdString = req.parameters.get("refinementSessionID"),
        let refinementSessionId = UUID(uuidString: refinementSessionIdString)
        else { throw Abort(.badRequest) }

        let refinementSession = try await RefinementSession.query(on: req.db)
            .filter(\.$id == refinementSessionId)
            .with(\.$userStories)
            .first()
        guard let refinementSession else { throw Abort(.notFound) }
        let refinementSessionData = RefinementSessionData(refinementSession: refinementSession)
        return try await req.view.render("refinementSession", refinementSessionData)
    }

    func context(req: Request) async throws -> Context {
        let count = try await RefinementSession.query(on: req.db).count()
        return Context(
            count: count,
            maximum: RefinementSession.maximumAllowed
        )
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
