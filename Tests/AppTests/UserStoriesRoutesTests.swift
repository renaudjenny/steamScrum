//
//  UserStoriesRoutesTests.swift
//  AppTests
//
//  Created by Renaud JENNY on 30/06/2018.
//

@testable import App
import XCTest
import FluentPostgreSQL
import Vapor

class UserStoriesRoutesTests: XCTestCase {

    var app: Application!
    var connection: PostgreSQLConnection!

    override func setUp() {
        super.setUp()
        try! Application.reset()
        self.app = try! Application.testable()
        self.connection = try! app.newConnection(to: .psql).wait()
    }

    override func tearDown() {
        self.connection.close()
        super.tearDown()
    }

    func testGetUserStoriesRoute() {
        let route = "/userStories"
        let userStoryName = "User story test GET"

        let userStory = UserStory(id: nil, name: userStoryName)
        _ = try! userStory.save(on: self.connection).wait()

        let receivedUserStories = try! self.app.getResponse(to: route, decodeTo: [UserStory].self)

        XCTAssertEqual(receivedUserStories.count, 1)
        XCTAssertEqual(receivedUserStories[0].name, userStoryName)
    }
    
    func testPostUserStoriesRoute() {
        let route = "/userStories"
        let userStoryName = "User story test POST"

        let userStory = UserStory(id: nil, name: userStoryName)

        let receivedUserStory = try! app.getResponse(to: route, method: .POST, headers: ["Content-Type": "application/json"], data: userStory, decodeTo: UserStory.self)

        XCTAssertEqual(receivedUserStory.name, userStoryName)
        XCTAssertNotNil(receivedUserStory.id)

        let receivedUserStories = try! app.getResponse(to: route, decodeTo: [UserStory].self)

        XCTAssertEqual(receivedUserStories.count, 1)
        XCTAssertEqual(receivedUserStories[0].name, userStoryName)
        XCTAssertEqual(receivedUserStories[0].id, receivedUserStory.id)
    }

    func testPostUserStoriesStoryPointsRoute() {
        let routeFirstPart = "/userStories"
        let routeSecondPart = "storyPoints"
        let userStoryPointValue1 = 3.0
        let userStoryPointUser1 = "Mario"
        let userStoryPointValue2 = 13.0
        let userStoryPointUser2 = "Luigi"
        let userStoryName = "User story test Post of Story Point"

        let userStory = try! UserStory(id: nil, name: userStoryName).save(on: self.connection).wait()
        let userStoryId = userStory.id!

        var receivedUserStories = try! app.getResponse(to: routeFirstPart, decodeTo: [UserStory].self)

        XCTAssertEqual(receivedUserStories[0].name, userStoryName)
        var receivedStoryPoints = try! receivedUserStories[0].storyPoints.query(on: self.connection).all().wait()
        XCTAssertEqual(receivedStoryPoints.count, 0)

        var storyPoint = UserStory.StoryPoint(id: nil, points: userStoryPointValue1, user: userStoryPointUser1, userStoryId: userStoryId)
        _ = try! app.getResponse(to: "\(routeFirstPart)/\(userStoryId)/\(routeSecondPart)", method: .POST, headers: ["Content-Type": "application/json"], data: storyPoint, decodeTo: UserStory.self)

        storyPoint = UserStory.StoryPoint(id: nil, points: userStoryPointValue2, user: userStoryPointUser2, userStoryId: userStoryId)
        let receivedUserStory = try! app.getResponse(to: "\(routeFirstPart)/\(userStoryId)/\(routeSecondPart)", method: .POST, headers: ["Content-Type": "application/json"], data: storyPoint, decodeTo: UserStory.self)

        XCTAssertEqual(receivedUserStory.id, userStoryId)

        receivedUserStories = try! app.getResponse(to: routeFirstPart, decodeTo: [UserStory].self)
        receivedStoryPoints = try! receivedUserStories[0].storyPoints.query(on: self.connection).all().wait()
        XCTAssertEqual(receivedStoryPoints.count, 2)
        XCTAssertEqual(receivedStoryPoints[0].points, userStoryPointValue1)
        XCTAssertEqual(receivedStoryPoints[0].user, userStoryPointUser1)
        XCTAssertEqual(receivedStoryPoints[1].points, userStoryPointValue2)
        XCTAssertEqual(receivedStoryPoints[1].user, userStoryPointUser2)


        let anotherUserStoryPointValue = 5.0
        let anotherUserStoryPointUser = "Peach"
        let anotherUserStoryName = "User story test another Post of Story Point"

        let anotherUserStory = try! UserStory(id: nil, name: anotherUserStoryName).save(on: self.connection).wait()
        let anotherUserStoryId = anotherUserStory.id!
        XCTAssertNotEqual(anotherUserStoryId, userStoryId)

        let anotherStoryPoint = UserStory.StoryPoint(id: nil, points: anotherUserStoryPointValue, user: anotherUserStoryPointUser, userStoryId: anotherUserStoryId)
        let otherReceivedUserStory = try! app.getResponse(to: "\(routeFirstPart)/\(anotherUserStoryId)/\(routeSecondPart)", method: .POST, headers: ["Content-Type": "application/json"], data: anotherStoryPoint, decodeTo: UserStory.self)

        XCTAssertEqual(otherReceivedUserStory.id, anotherUserStoryId)

        receivedUserStories = try! app.getResponse(to: routeFirstPart, decodeTo: [UserStory].self)
        XCTAssertEqual(receivedUserStories.count, 2)
        receivedStoryPoints = try! receivedUserStories[1].storyPoints.query(on: self.connection).all().wait()
        XCTAssertEqual(receivedStoryPoints.count, 1)
        XCTAssertEqual(receivedStoryPoints[0].points, anotherUserStoryPointValue)
        XCTAssertEqual(receivedStoryPoints[0].user, anotherUserStoryPointUser)
    }

    func testPostUserStoriesStoryPointsWithoutExplicitIdRoute() {
        let routeFirstPart = "/userStories"
        let routeSecondPart = "storyPoints"
        let userStoryPointValue1 = 3.0
        let userStoryPointUser1 = "Mario"
        let userStoryPointValue2 = 13.0
        let userStoryPointUser2 = "Luigi"
        let userStoryName = "User story test Post of Story Point"

        let userStory = try! UserStory(id: nil, name: userStoryName).save(on: self.connection).wait()
        let userStoryId = userStory.id!

        var receivedUserStories = try! app.getResponse(to: routeFirstPart, decodeTo: [UserStory].self)

        XCTAssertEqual(receivedUserStories[0].name, userStoryName)
        var receivedStoryPoints = try! receivedUserStories[0].storyPoints.query(on: self.connection).all().wait()
        XCTAssertEqual(receivedStoryPoints.count, 0)

        var storyPoint = UserStory.StoryPoint(id: nil, points: userStoryPointValue1, user: userStoryPointUser1, userStoryId: nil)
        _ = try! app.getResponse(to: "\(routeFirstPart)/\(userStoryId)/\(routeSecondPart)", method: .POST, headers: ["Content-Type": "application/json"], data: storyPoint, decodeTo: UserStory.self)

        storyPoint = UserStory.StoryPoint(id: nil, points: userStoryPointValue2, user: userStoryPointUser2, userStoryId: nil)
        let receivedUserStory = try! app.getResponse(to: "\(routeFirstPart)/\(userStoryId)/\(routeSecondPart)", method: .POST, headers: ["Content-Type": "application/json"], data: storyPoint, decodeTo: UserStory.self)

        XCTAssertEqual(receivedUserStory.id, userStoryId)

        receivedUserStories = try! app.getResponse(to: routeFirstPart, decodeTo: [UserStory].self)
        receivedStoryPoints = try! receivedUserStories[0].storyPoints.query(on: self.connection).all().wait()
        XCTAssertEqual(receivedStoryPoints.count, 2)
        XCTAssertEqual(receivedStoryPoints[0].points, userStoryPointValue1)
        XCTAssertEqual(receivedStoryPoints[0].user, userStoryPointUser1)
        XCTAssertEqual(receivedStoryPoints[1].points, userStoryPointValue2)
        XCTAssertEqual(receivedStoryPoints[1].user, userStoryPointUser2)


        let anotherUserStoryPointValue = 5.0
        let anotherUserStoryPointUser = "Peach"
        let anotherUserStoryName = "User story test another Post of Story Point"

        let anotherUserStory = try! UserStory(id: nil, name: anotherUserStoryName).save(on: self.connection).wait()
        let anotherUserStoryId = anotherUserStory.id!
        XCTAssertNotEqual(anotherUserStoryId, userStoryId)

        let anotherStoryPoint = UserStory.StoryPoint(id: nil, points: anotherUserStoryPointValue, user: anotherUserStoryPointUser, userStoryId: nil)
        let otherReceivedUserStory = try! app.getResponse(to: "\(routeFirstPart)/\(anotherUserStoryId)/\(routeSecondPart)", method: .POST, headers: ["Content-Type": "application/json"], data: anotherStoryPoint, decodeTo: UserStory.self)

        XCTAssertEqual(otherReceivedUserStory.id, anotherUserStoryId)

        receivedUserStories = try! app.getResponse(to: routeFirstPart, decodeTo: [UserStory].self)
        XCTAssertEqual(receivedUserStories.count, 2)
        receivedStoryPoints = try! receivedUserStories[1].storyPoints.query(on: self.connection).all().wait()
        XCTAssertEqual(receivedStoryPoints.count, 1)
        XCTAssertEqual(receivedStoryPoints[0].points, anotherUserStoryPointValue)
        XCTAssertEqual(receivedStoryPoints[0].user, anotherUserStoryPointUser)
    }

    static let allTests = [
        ("testGetUserStoriesRoute", testGetUserStoriesRoute),
        ("testPostUserStoriesRoute", testPostUserStoriesRoute),
        ("testPostUserStoriesStoryPointsRoute", testPostUserStoriesStoryPointsRoute),
        ("testPostUserStoriesStoryPointsWithoutExplicitIdRoute", testPostUserStoriesStoryPointsWithoutExplicitIdRoute)
    ]
}
