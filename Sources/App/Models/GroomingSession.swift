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
    var userStories: Children<GroomingSession, UserStory> {
        return self.children(\.groomingSessionId)
    }
}

extension GroomingSession: Migration { }

extension GroomingSession: Content { }

extension GroomingSession: Parameter { }
