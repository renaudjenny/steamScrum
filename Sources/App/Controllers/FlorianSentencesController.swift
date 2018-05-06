//
//  FlorianSentencesController.swift
//  App
//
//  Created by Renaud JENNY on 04/05/2018.
//

import Vapor
import Leaf

final class FlorianSentencesController {

    static let maximumSentencesCount = 250

    func index(_ req: Request) throws -> Future<[FlorianSentence]> {
        return FlorianSentence.query(on: req).all()
    }

    func create(_ req: Request) throws -> Future<FlorianSentence> {
        return FlorianSentence.query(on: req).count().flatMap({ (count) -> EventLoopFuture<FlorianSentence> in
            guard count <= FlorianSentencesController.maximumSentencesCount else {
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

    func florianSentenceForm(_ req: Request) throws -> Future<View> {
        return FlorianSentence.query(on: req).count().flatMap { (count) -> EventLoopFuture<View> in
            let leaf = try req.make(LeafRenderer.self)
            let context = Context(
                sentencesCount: count,
                maximumSentencesCount: FlorianSentencesController.maximumSentencesCount,
                newSentence: nil
            )
            return leaf.render("florianSentenceForm", context)
        }
    }

    func AddFlorianSentenceFromForm(_ req: Request) throws -> Future<View> {
        let florianSentence = try req.content.decode(FormResponse.self).map { (formResponse) -> FlorianSentence in
            return FlorianSentence(sentence: formResponse.sentence)
        }

        return florianSentence.save(on: req).flatMap { (florianSentence) -> EventLoopFuture<View> in
            return FlorianSentence.query(on: req).count().flatMap { (count) -> EventLoopFuture<View> in
                let leaf = try req.make(LeafRenderer.self)
                let context = Context(
                    sentencesCount: count,
                    maximumSentencesCount: FlorianSentencesController.maximumSentencesCount,
                    newSentence: florianSentence.sentence
                )
                return leaf.render("florianSentenceForm", context)
            }
        }
    }
}

// MARK: - Inner types
extension FlorianSentencesController {
    struct Context: Codable {
        var sentencesCount: Int
        var maximumSentencesCount: Int
        var newSentence: String?
    }

    struct FormResponse: Codable {
        var sentence: String
    }
}
