//
//  GroomingSession.swift
//  App
//
//  Created by Renaud JENNY on 10/05/2018.
//

import FluentPostgreSQL
import Vapor

struct GroomingSession: PostgreSQLModel {
    var id: Int?
    var name: String
    var date: Date
}

// MARK: - Inner Types
extension GroomingSession {
    struct DeveloperEstimation: Codable {
        var developer: Developer
        var userStory: UserStory
    }
}

extension GroomingSession: Migration { }

extension GroomingSession: Content { }

extension GroomingSession: Parameter { }
