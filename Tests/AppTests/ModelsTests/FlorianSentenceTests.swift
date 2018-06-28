//
//  FlorianSentenceTests.swift
//  AppTests
//
//  Created by Renaud JENNY on 27/06/2018.
//

import XCTest
@testable import App

class FlorianSentenceTests: XCTestCase {

    func testInitWithSentence() {
        let florianSentence = FlorianSentence(sentence: "test")
        XCTAssertEqual(florianSentence.sentence, "test")
    }
}
