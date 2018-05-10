//
//  FlorianSentence.swift
//  App
//
//  Created by Renaud JENNY on 04/05/2018.
//

import FluentPostgreSQL
import Vapor

struct FlorianSentence: PostgreSQLModel {
    var id: Int?
    var sentence: String
    var upvoteCount: Int?
    var downvoteCount: Int?

    init(sentence: String) {
        self.sentence = sentence
    }
}

extension FlorianSentence: Migration { }

extension FlorianSentence: Content { }

extension FlorianSentence: Parameter { }
