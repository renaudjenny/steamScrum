//
//  UserStoryController.swift
//  App
//
//  Created by Renaud JENNY on 20/06/2018.
//

import Vapor

final class UserStoryController {

    func index(_ req: Request) throws -> Future<[UserStory]> {
        return UserStory.query(on: req).all()
    }

    func create(_ req: Request) throws -> Future<UserStory> {
        return try req.content.decode(UserStory.self).flatMap(to: UserStory.self) { (userStory) in
            return userStory.save(on: req)
        }
    }

    func addStoryPoints(_ req: Request) throws -> Future<UserStory> {
        return try req.content.decode(UserStory.StoryPoint.self).flatMap(to: UserStory.self) { (storyPoint) in
            return try req.parameters.next(UserStory.self).map(to: UserStory.self, { (userStory) -> UserStory in
                guard let userStoryId = userStory.id else {
                    throw Abort(.badRequest, reason: "Cannot retrieve Story Point Id.", identifier: nil)
                }

                var mutableStoryPoint = storyPoint
                if mutableStoryPoint.userStoryId == nil {
                    mutableStoryPoint.userStoryId = userStory.id
                }

                guard mutableStoryPoint.userStoryId == userStoryId else {
                    throw Abort(.conflict, reason: "User Story Id in URL and User Story Id in userStory property is not the same.", identifier: nil)
                }

                _ = mutableStoryPoint.save(on: req)
                return userStory
            })
        }
    }
}