//
//  GroomingSessionControllerTests.swift
//  AppTests
//
//  Created by Renaud JENNY on 27/06/2018.
//

import XCTest
import Vapor

class GroomingSessionControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIndex() {
        XCTFail("Test not implemented")
        /*
        let groomingSessionController = GroomingSessionController()
        let container = Container()
        container.make(Client.self)
        let request = HTTPRequest(method: .GET, url: "", version: .init(major: 1, minor: 1), headers: HTTPHeaders([]), body: "")
        let futur = groomingSessionController.index(Request(http: request, using: container))
 */
    }

    func testCreate() {
        XCTFail("Test not implemented")
    }
}
