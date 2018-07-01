@testable import App
import XCTest
import FluentPostgreSQL
import Vapor

final class FlorianSentencesRoutesTests: XCTestCase {

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

    func testGetFlorianSentencesRoute() throws {
        let route = "/florianSentences"
        let sentence = "Test sentence"
        let florianSentence = FlorianSentence(sentence: sentence)
        _ = try! florianSentence.save(on: self.connection).wait()

        let florianSentences = try! app.getResponse(to: route, decodeTo: [FlorianSentence].self)

        XCTAssertEqual(florianSentences.count, 1)
        XCTAssertEqual(florianSentences[0].sentence, sentence)
    }

    func testPostFlorianSentencesRoute() throws {
        let route = "/florianSentences"
        let sentence = "Test sentence for POST"
        let florianSentence = FlorianSentence(sentence: sentence)

        let receivedFlorianSentence = try! app.getResponse(to: route, method: .POST, headers: ["Content-Type": "application/json"], data: florianSentence, decodeTo: FlorianSentence.self)

        XCTAssertEqual(receivedFlorianSentence.sentence, sentence)
        XCTAssertNotNil(receivedFlorianSentence.id)

        let florianSentences = try! app.getResponse(to: route, decodeTo: [FlorianSentence].self)

        XCTAssertEqual(florianSentences.count, 1)
        XCTAssertEqual(florianSentences[0].sentence, sentence)
        XCTAssertEqual(florianSentences[0].id, receivedFlorianSentence.id)
    }

    func testPatchFlorianSentencesRoute() throws {
        let route = "/florianSentences"
        let sentence = "Test sentence for PATCH"
        let modifiedSentence = "Test sentence for PATCH modified"
        var florianSentence = FlorianSentence(sentence: sentence)

        let newFlorianSentence = try! florianSentence.save(on: self.connection).wait()

        XCTAssertEqual(newFlorianSentence.sentence, sentence)
        XCTAssertNotNil(newFlorianSentence.id)

        let sentenceId = newFlorianSentence.id

        florianSentence.sentence = modifiedSentence
        let modifiedFlorianSentence = try! app.getResponse(to: "\(route)/\(sentenceId!)", method: .PATCH, headers: ["Content-Type": "application/json"], data: florianSentence, decodeTo: FlorianSentence.self)

        XCTAssertEqual(modifiedFlorianSentence.sentence, modifiedSentence)
        XCTAssertEqual(modifiedFlorianSentence.id, sentenceId)

        let florianSentences = try! app.getResponse(to: route, decodeTo: [FlorianSentence].self)

        XCTAssertEqual(florianSentences.count, 1)
        XCTAssertEqual(florianSentences[0].sentence, modifiedSentence)
        XCTAssertEqual(florianSentences[0].id, sentenceId)
    }

    func testDeleteFlorianSentencesRoute() throws {
        let route = "/florianSentences"
        let sentence = "Test sentence for DELETE"
        let florianSentence = FlorianSentence(sentence: sentence)

        let newFlorianSentence = try! florianSentence.save(on: self.connection).wait()

        var florianSentences = try! app.getResponse(to: route, decodeTo: [FlorianSentence].self)

        XCTAssertEqual(florianSentences.count, 1)

        let sentenceId = newFlorianSentence.id

        _ = try! app.sendRequest(to: "\(route)/\(sentenceId!)", method: .DELETE)

        florianSentences = try! app.getResponse(to: route, decodeTo: [FlorianSentence].self)

        XCTAssertEqual(florianSentences.count, 0)
    }

    func testRandomFlorianSentenceRoute() {
        let route = "/randomFlorianSentence"
        let emptyFlorianSentence = "Je n'ai aucune phrase pour le moment. Utilise le formulaire pour en ajouter une 😊 !"
        let sentences = ["First sentence", "Second sentence", "Third sentence"]

        var receivedFlorianSentence = try! app.getResponse(to: route, decodeTo: FlorianSentence.self)
        XCTAssertEqual(receivedFlorianSentence.sentence, emptyFlorianSentence)

        for sentence in sentences {
            _ = try! FlorianSentence(sentence: sentence).save(on: self.connection).wait()
        }

        var randomCounts = [sentences[0]: 0, sentences[1]: 0, sentences[2]: 0]
        for _ in 0..<50 {
            receivedFlorianSentence = try! app.getResponse(to: route, decodeTo: FlorianSentence.self)
            XCTAssertNotEqual(receivedFlorianSentence.sentence, emptyFlorianSentence)
            XCTAssertTrue(sentences.contains(receivedFlorianSentence.sentence))
            randomCounts[receivedFlorianSentence.sentence]! += 1
        }

        XCTAssertGreaterThan(randomCounts[sentences[0]]!, 0)
        XCTAssertGreaterThan(randomCounts[sentences[1]]!, 0)
        XCTAssertGreaterThan(randomCounts[sentences[2]]!, 0)
    }

    func testFlorianSentencesContext() {
        let route = "/florianSentencesContext"
        let maximumSentencesCount = 250

        var context = try! app.getResponse(to: route, decodeTo: FlorianSentencesController.Context.self)
        XCTAssertEqual(context.sentencesCount, 0)
        XCTAssertEqual(context.maximumSentencesCount, maximumSentencesCount)

        _ = try! FlorianSentence(sentence: "...").save(on: self.connection).wait()
        context = try! app.getResponse(to: route, decodeTo: FlorianSentencesController.Context.self)
        XCTAssertEqual(context.sentencesCount, 1)

        for i in 0..<10 {
            _ = try! FlorianSentence(sentence: "... \(i)").save(on: self.connection).wait()
        }
        context = try! app.getResponse(to: route, decodeTo: FlorianSentencesController.Context.self)
        XCTAssertEqual(context.sentencesCount, 11)
    }

    static let allTests = [
        ("testGetFlorianSentencesRoute", testGetFlorianSentencesRoute),
        ("testPostFlorianSentencesRoute", testPostFlorianSentencesRoute),
        ("testPatchFlorianSentencesRoute", testPatchFlorianSentencesRoute),
        ("testDeleteFlorianSentencesRoute", testDeleteFlorianSentencesRoute),
        ("testRandomFlorianSentenceRoute", testRandomFlorianSentenceRoute),
        ("testFlorianSentencesContext", testFlorianSentencesContext),
    ]
}
