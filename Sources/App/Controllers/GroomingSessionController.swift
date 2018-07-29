//
//  GroomingSessionController.swift
//  App
//
//  Created by Renaud JENNY on 25/05/2018.
//

import Vapor

final class GroomingSessionController {

    static let maximumGroomingSessionsCount = 250

    func index(_ req: Request) throws -> Future<[GroomingSession]> {
        return GroomingSession.query(on: req).all()
    }

    func create(_ req: Request) throws -> Future<GroomingSession> {
        return GroomingSession.query(on: req).count().flatMap({ (count) -> EventLoopFuture<GroomingSession> in
            guard count < FlorianSentencesController.maximumSentencesCount else {
                throw Abort(.badRequest, reason: "Too many data already provided.", identifier: nil)
            }
            return try req.content.decode(GroomingSession.self)
        }).flatMap({ (groomingSession) -> EventLoopFuture<GroomingSession> in
            guard !groomingSession.name.isEmpty else {
                throw Abort(.badRequest, reason: "Cannot provide empty string for name.", identifier: nil)
            }
            return groomingSession.save(on: req)
        })
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(GroomingSession.self).flatMap({ (groomingSession) -> EventLoopFuture<HTTPStatus> in
            return groomingSession.delete(on: req).transform(to: .ok)
        })
    }

    func context(_ req: Request) throws -> Future<Context> {
        return GroomingSession.query(on: req).count().map { (count) -> Context in
            let context = Context(
                groomingSessionsCount: count,
                maximumGroomingSessionsCount: GroomingSessionController.maximumGroomingSessionsCount
            )
            return context
        }
    }
}

// MARK: - Inner types
extension GroomingSessionController {
    struct Context: Content {
        var groomingSessionsCount: Int
        var maximumGroomingSessionsCount: Int
    }
}
