//
//  UserStoryController.swift
//  App
//
//  Created by Renaud JENNY on 20/06/2018.
//

import Vapor

final class UserStoryController {

    func create(_ req: Request) throws -> Future<UserStory> {
        return try req.content.decode(UserStory.self).flatMap(to: UserStory.self) { (userStory) in
            return userStory.save(on: req)
        }
    }

    func addStoryPoints(_ req: Request) throws -> Future<UserStory> {
        return try req.content.decode(UserStory.StoryPoint.self).flatMap(to: UserStory.self) { (storyPoint) in
            return try req.parameters.next(UserStory.self).map(to: UserStory.self, { (userStory) -> UserStory in
                storyPoint.save(on: req)
                return userStory
            })
        }
    }
}
