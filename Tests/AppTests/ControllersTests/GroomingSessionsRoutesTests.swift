//
//  GroomingSessionsRoutesTests.swift
//  AppTests
//
//  Created by Renaud JENNY on 30/06/2018.
//

@testable import App
import XCTest
import FluentPostgreSQL
import Vapor

class GroomingSessionsRoutesTests: XCTestCase {

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
    
    func testGetGroomingSessionsRoute() {
        let route = "/groomingSessions"
        let groomingSessionName = "Grooming test GET"
        let groomingSessionDate = Date(timeIntervalSince1970: 1.0)

        let groomingSession = GroomingSession(id: nil, name: groomingSessionName, date: groomingSessionDate)
        _ = try! groomingSession.save(on: self.connection).wait()

        let receivedGroomingSessions = try! self.app.getResponse(to: route, decodeTo: [GroomingSession].self)

        XCTAssertEqual(receivedGroomingSessions.count, 1)
        XCTAssertEqual(receivedGroomingSessions[0].name, groomingSessionName)
        XCTAssertEqual(receivedGroomingSessions[0].date, groomingSessionDate)
    }

    func testPostGroomingSessionRoute() {
        let route = "/groomingSessions"
        let groomingSessionName = "Grooming test POST"
        let groomingSessionDate = Date(timeIntervalSince1970: 1.0)

        let groomingSession = GroomingSession(id: nil, name: groomingSessionName, date: groomingSessionDate)

        let receivedGroomingSession = try! app.getResponse(to: route, method: .POST, headers: ["Content-Type": "application/json"], data: groomingSession, decodeTo: GroomingSession.self)

        XCTAssertEqual(receivedGroomingSession.name, groomingSessionName)
        XCTAssertEqual(receivedGroomingSession.date, groomingSessionDate)
        XCTAssertNotNil(receivedGroomingSession.id)

        let receivedGroomingSessions = try! app.getResponse(to: route, decodeTo: [GroomingSession].self)

        XCTAssertEqual(receivedGroomingSessions.count, 1)
        XCTAssertEqual(receivedGroomingSessions[0].name, groomingSessionName)
        XCTAssertEqual(receivedGroomingSessions[0].date, groomingSessionDate)
        XCTAssertEqual(receivedGroomingSessions[0].id, receivedGroomingSession.id)
    }

    func testPostMaximumFlorianSentencesRoute() throws {
        let route = "/groomingSessions"
        let groomingSessionName = "Grooming test POST"
        let groomingSessionDate = Date(timeIntervalSince1970: 1.0)

        let groomingSession = GroomingSession(id: nil, name: groomingSessionName, date: groomingSessionDate)

        for _ in 0..<FlorianSentencesController.maximumSentencesCount {
            _ = try! app.getResponse(to: route, method: .POST, headers: ["Content-Type": "application/json"], data: groomingSession, decodeTo: GroomingSession.self)
        }

        let receivedGroomingSessions = try! app.getResponse(to: route, decodeTo: [GroomingSession].self)

        XCTAssertEqual(receivedGroomingSessions.count, GroomingSessionController.maximumGroomingSessionsCount)

        XCTAssertThrowsError(
            try app.getResponse(to: route, method: .POST, headers: ["Content-Type": "application/json"], data: groomingSession, decodeTo: GroomingSession.self)
        )
    }

    func testGetGroomingSessionsContext() {
        let route = "/groomingSessionsContext"
        let maximumGroomingSessionsCount = 250

        var context = try! app.getResponse(to: route, decodeTo: GroomingSessionController.Context.self)
        XCTAssertEqual(context.groomingSessionsCount, 0)
        XCTAssertEqual(context.maximumGroomingSessionsCount, maximumGroomingSessionsCount)

        _ = try! GroomingSession(id: nil, name: "...", date: Date()).save(on: self.connection).wait()
        context = try! app.getResponse(to: route, decodeTo: GroomingSessionController.Context.self)
        XCTAssertEqual(context.groomingSessionsCount, 1)

        for i in 0..<10 {
            _ = try! GroomingSession(id: nil, name: "... \(i)", date: Date()).save(on: self.connection).wait()
        }
        context = try! app.getResponse(to: route, decodeTo: GroomingSessionController.Context.self)
        XCTAssertEqual(context.groomingSessionsCount, 11)
    }

    func testDeleteGroomingSession() {
        let route = "/groomingSessions"
        let groomingSessionName = "Grooming test DELETE"
        let groomingSessionDate = Date(timeIntervalSince1970: 1.0)

        let groomingSession = GroomingSession(id: nil, name: groomingSessionName, date: groomingSessionDate)
        let createdGroomingSession = try! groomingSession.save(on: self.connection).wait()

        var receivedGroomingSessions = try! self.app.getResponse(to: route, decodeTo: [GroomingSession].self)

        XCTAssertEqual(receivedGroomingSessions.count, 1)
        XCTAssertEqual(receivedGroomingSessions[0].name, groomingSessionName)
        XCTAssertEqual(receivedGroomingSessions[0].date, groomingSessionDate)

        _ = try! self.app.sendRequest(to: "\(route)/\(createdGroomingSession.id!)", method: .DELETE)

        receivedGroomingSessions = try! self.app.getResponse(to: route, decodeTo: [GroomingSession].self)

        XCTAssertEqual(receivedGroomingSessions.count, 0)
    }

    func testGetGroomingSession() {
        let route = "/groomingSessions"
        let groomingSessionName = "Grooming test GET"
        let groomingSessionDate = Date(timeIntervalSince1970: 1.0)

        let groomingSession = GroomingSession(id: nil, name: groomingSessionName, date: groomingSessionDate)
        let createdGroomingSession = try! groomingSession.save(on: self.connection).wait()

        var receivedGroomingSession = try! self.app.getResponse(to: "\(route)/\(createdGroomingSession.id!)", decodeTo: GroomingSessionController.GroomingSessionFullContent.self)

        XCTAssertEqual(receivedGroomingSession.name, groomingSessionName)
        XCTAssertEqual(receivedGroomingSession.date, groomingSessionDate)
        XCTAssertEqual(receivedGroomingSession.userStories.count, 0)

        let userStory = try! UserStory(id: nil, name: "User story", groomingSessionId: receivedGroomingSession.id!).save(on: self.connection).wait()
        receivedGroomingSession = try! self.app.getResponse(to: "\(route)/\(createdGroomingSession.id!)", decodeTo: GroomingSessionController.GroomingSessionFullContent.self)
        XCTAssertEqual(receivedGroomingSession.userStories.count, 1)
        XCTAssertEqual(receivedGroomingSession.userStories.first?.name, userStory.name)
    }

    static let allTests = [
        ("testGetGroomingSessionsRoute", testGetGroomingSessionsRoute),
        ("testPostGroomingSessionRoute", testPostGroomingSessionRoute),
        ("testGetGroomingSessionsContext", testGetGroomingSessionsContext),
        ("testPostMaximumFlorianSentencesRoute", testPostMaximumFlorianSentencesRoute),
        ("testDeleteGroomingSession", testDeleteGroomingSession),
        ("testGetGroomingSession", testGetGroomingSession),
    ]
}
