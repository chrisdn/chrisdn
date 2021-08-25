//
//  Lonpos3DTests.swift
//  Lonpos3DTests
//
//  Created by Wei Dong on 2021-08-25.
//

import XCTest
@testable import Lonpos3D

class Lonpos3DTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMostDifficultLevel() throws {
        var game = Game()
        for _ in 0...54 {
            let p = game.mostDifficultPosition
            XCTAssert(p != nil)
            print(p!)
            game.space[p!.index()] = "8"
        }
        let p = game.mostDifficultPosition
        print(p)
        XCTAssert(p == nil)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
