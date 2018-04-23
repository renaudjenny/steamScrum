//
//  FlorianController.swift
//  App
//
//  Created by Renaud JENNY on 23/04/2018.
//

import Vapor
import HTTP
import Leaf

final class FlorianController {
    
    func whatFlorianSaid(_ req: Request) throws -> Future<View> {
        let sentences = [
            "Quel est le vrai problème ?",
            "Tu as demandé à Olivier ?",
            "🤷🏻‍♂️"
        ]

        let randomIndex = Int(arc4random_uniform(UInt32(sentences.count)))

        struct Context: Codable {
            var sentence: String
        }

        let context = Context(sentence: sentences[randomIndex])

        let leaf = try req.make(LeafRenderer.self)
        return leaf.render("florian", context)
    }
}
