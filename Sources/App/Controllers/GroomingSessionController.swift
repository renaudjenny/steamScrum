//
//  GroomingSessionController.swift
//  App
//
//  Created by Renaud JENNY on 25/05/2018.
//

import Vapor

final class GroomingSessionController {

    func index(_ req: Request) throws -> Future<[GroomingSession]> {
        return GroomingSession.query(on: req).all()
    }

    func create(_ req: Request) throws -> Future<GroomingSession> {
        return try req.content.decode(GroomingSession.self).flatMap(to: GroomingSession.self) { groomingSession in
            return groomingSession.save(on: req)
        }
    }
}
