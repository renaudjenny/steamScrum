//
//  UserStory.swift
//  App
//
//  Created by Renaud JENNY on 10/05/2018.
//

import FluentPostgreSQL
import Vapor

struct UserStory: PostgreSQLModel {
    var id: Int?
    var name: String
}

// MARK: - Inner Types

extension UserStory {
    struct EstimatedPoint: Codable {
        var date: Date
        var points: Double
    }
}

extension UserStory: Migration { }

extension UserStory: Content { }

extension UserStory: Parameter { }
