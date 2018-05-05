//
//  FlorianController.swift
//  App
//
//  Created by Renaud JENNY on 23/04/2018.
//

import Vapor
import HTTP
import Leaf
import Random

final class FlorianController {
    
    func whatFlorianSaid(_ req: Request) throws -> Future<View> {
        return FlorianSentence.query(on: req).all().flatMap { (florianSentences: [FlorianSentence]) -> EventLoopFuture<View> in
            let sentencesCount = UInt(florianSentences.count)
            let randomIndex: Int = try Int(OSRandom().generate() % sentencesCount)
            struct Context: Codable {
                var sentence: String
            }

            let context = Context(sentence: florianSentences[randomIndex].sentence)

            let leaf = try req.make(LeafRenderer.self)
            return leaf.render("florian", context)
        }
    }
}
