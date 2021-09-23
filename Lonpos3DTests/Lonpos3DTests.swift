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
    
    func testPointToIndex() {
        let i = Point2d(x: 3, y: 6).index
        print(i)
        XCTAssert(i == 24)
    }
    
    func testGetDistanceMap() {
        var table = [] as [Int]
        for index1 in 0...54 {
            let p1 = Game2d.rowColumn(index: index1)
            for index2 in 0...54 {
                if index1 == index2 {
                    table.append(0)
                } else {
                    let p2 = Game2d.rowColumn(index: index2)
                    let dx = p1.x - p2.x
                    let dy = p1.y - p2.y
                    let distance = dx * dx + dy * dy
                    table.append(distance)
                }
            }
        }
        print(table.count, table)
        XCTAssert(table.count == 55 * 55)
        XCTAssert(table[3] == 4)
        XCTAssert(table[3 * 55] == 4)
        let p1 = Point2d(x: 3, y: 7)
        let p2 = Point2d(x: 2, y: 4)
        XCTAssert(table[p1.index * 55 + p2.index] == 10)
    }
    
    func testWoodoku() {
        for p in Woodoku.PieceType.allCases {
            print(p.piece)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
