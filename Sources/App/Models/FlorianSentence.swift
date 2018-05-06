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

/// Allows `Todo` to be used as a dynamic migration.
extension FlorianSentence: Migration { }

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension FlorianSentence: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension FlorianSentence: Parameter { }
