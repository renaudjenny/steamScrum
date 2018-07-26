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
        return try req.content.decode(GroomingSession.self).flatMap(to: GroomingSession.self) { groomingSession in
            return groomingSession.save(on: req)
        }
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
