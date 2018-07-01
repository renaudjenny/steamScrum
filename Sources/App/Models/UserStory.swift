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
    struct StoryPoint: PostgreSQLModel {
        var id: Int?
        var points: Double
        var user: String
        var userStoryId: UserStory.ID?
    }

    var storyPoints: Children<UserStory, StoryPoint> {
        return self.children(\.userStoryId)
    }
}

extension UserStory: Migration { }

extension UserStory: Content { }

extension UserStory: Parameter { }

extension UserStory.StoryPoint: Migration { }

extension UserStory.StoryPoint: Content { }

extension UserStory.StoryPoint: Parameter { }
