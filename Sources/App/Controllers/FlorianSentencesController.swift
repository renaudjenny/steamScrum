//
//  FlorianSentencesController.swift
//  App
//
//  Created by Renaud JENNY on 04/05/2018.
//

import Vapor

final class FlorianSentencesController {

    func index(_ req: Request) throws -> Future<[FlorianSentence]> {
        return FlorianSentence.query(on: req).all()
    }

    func create(_ req: Request) throws -> Future<FlorianSentence> {
        return FlorianSentence.query(on: req).count().flatMap({ (count) -> EventLoopFuture<FlorianSentence> in
            guard count <= 250 else {
                throw Abort(.badRequest, reason: "Too many data already provided.", identifier: nil)
            }

            return try req.content.decode(FlorianSentence.self).flatMap(to: FlorianSentence.self) { florianSentence in
                return florianSentence.save(on: req)
            }
        })
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(FlorianSentence.self).flatMap(to: Void.self) { florianSentence in
            return florianSentence.delete(on: req)
            }.transform(to: .ok)
    }
}
