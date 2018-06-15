//
//  FlorianSentencesController.swift
//  App
//
//  Created by Renaud JENNY on 04/05/2018.
//

import Vapor
import Random

final class FlorianSentencesController {

    static let maximumSentencesCount = 250

    func index(_ req: Request) throws -> Future<[FlorianSentence]> {
        return FlorianSentence.query(on: req).all()
    }

    func patch(_ req: Request) throws -> Future<FlorianSentence> {
        return try req.parameters.next(FlorianSentence.self).flatMap({ (florianSentence) -> EventLoopFuture<FlorianSentence> in
            let id = florianSentence.id
            return try req.content.decode(FlorianSentence.self).flatMap(to: FlorianSentence.self, { (florianSentence) in
                var newFlorianSentence = florianSentence
                newFlorianSentence.id = id
                return newFlorianSentence.update(on: req)
            })
        })
    }

    func create(_ req: Request) throws -> Future<FlorianSentence> {
        return FlorianSentence.query(on: req).count().flatMap({ (count) -> EventLoopFuture<FlorianSentence> in
            guard count <= FlorianSentencesController.maximumSentencesCount else {
                throw Abort(.badRequest, reason: "Too many data already provided.", identifier: nil)
            }

            return try req.content.decode(FlorianSentence.self).flatMap(to: FlorianSentence.self) { florianSentence in
                guard !florianSentence.sentence.isEmpty else {
                    throw Abort(.badRequest, reason: "Cannot provide empty string.", identifier: nil)
                }

                return florianSentence.save(on: req)
            }
        })
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(FlorianSentence.self).flatMap(to: Void.self) { florianSentence in
            return florianSentence.delete(on: req)
            }.transform(to: .ok)
    }

    func context(_ req: Request) throws -> Future<Context> {
        return FlorianSentence.query(on: req).count().map { (count) -> Context in
            let context = Context(
                sentencesCount: count,
                maximumSentencesCount: FlorianSentencesController.maximumSentencesCount
            )
            return context
        }
    }
    
    func randomFlorianSentence(_ req: Request) throws -> Future<FlorianSentence> {
        return FlorianSentence.query(on: req).all().map { (florianSentences: [FlorianSentence]) -> FlorianSentence in
            let sentencesCount = UInt(florianSentences.count)
            guard sentencesCount > 0 else {
                return FlorianSentence(sentence: "Je n'ai aucune phrase pour le moment. Utilise le formulaire pour en ajouter une 😊 !")
            }

            let randomIndex: Int = try Int(OSRandom().generate() % sentencesCount)
            let randomFlorianSentence = florianSentences[randomIndex]
            return randomFlorianSentence
        }
    }
}

// MARK: - Inner types
extension FlorianSentencesController {
    struct Context: Content {
        var sentencesCount: Int
        var maximumSentencesCount: Int
    }
}
