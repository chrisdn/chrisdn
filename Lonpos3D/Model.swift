//
//  Model.swift
//  Model
//
//  Created by Wei Dong on 2021-08-25.
//

import Foundation

struct PointInt3D {
    var x, y, z: Int
    static let sqrt2_2 = sqrtf(2) / 2
    
    func index(outOfBoundAllowed: Bool = false) -> Int {
        if z < 0 || z > 4 {return -1}
        if !((0...4 - z) ~= x) || !((0...4 - z) ~= y) {
            return -1
        }
        switch z {
        case 0:
            return y * 5 + x
        case 1:
            return y * 4 + x + 25
        case 2:
            return y * 3 + x + 41
        case 3:
            return y * 2 + x + 50
        case 4:
            return 54
        default:
            if outOfBoundAllowed {return -1}
            abort()
        }
    }
    
    static func point(from index: Int) -> PointInt3D {
        switch index {
        case 0..<25:
            return PointInt3D(x: index % 5, y: index / 5, z: 0)
        case 25..<41:
            return PointInt3D(x: (index - 25) % 4, y: (index - 25) / 4, z: 1)
        case 41..<50:
            return PointInt3D(x: (index - 41) % 3, y: (index - 41) / 3, z: 2)
        case 50...53:
            return PointInt3D(x: (index - 50) % 2, y: (index - 50) / 2, z: 3)
        case 54:
            return PointInt3D(x: 0, y: 0, z: 4)
        default:
            abort()
        }
    }
}

extension PointInt3D: CustomDebugStringConvertible {
    var debugDescription: String {
        "(\(x),\(y),\(z))"
    }
}

struct Piece {
    var identifier: Character
    var ballCount: Int
    var maxLength: Int
    var distanceSet: Set<[Int]>
    
    func isValidPoints(indexList: [Int]) -> Bool {
        var tSet = Set<[Int]>()
        for i in 0..<indexList.count {
            let index0 = indexList[i]
            var list = [Int]()
            for j in 0..<indexList.count where i != j {
                list.append(index0.distance(from: indexList[j]))
            }
            list.sort()
            if !distanceSet.contains(list) {
                return false
            }
            tSet.insert(list)
        }
        return tSet == distanceSet
    }
    
    static var H: Piece {
        /*
         HH
         H
         */
        return Piece(identifier: "H", ballCount: 3, maxLength: 2, distanceSet: [[1,2], [1,1]])
    }
    
    static var L: Piece {
        /* Shape L
         L
         L
         LL
         */
        return Piece(identifier: "L", ballCount: 4, maxLength: 5, distanceSet: [[1,4,5], [1,1,2], [1,1,4], [1,2,5]])
    }
    
    static var U: Piece {
        /* Umbrella
         U
         U
         U
         UU
         */
        return Piece(identifier: "U", ballCount: 5, maxLength: 10, distanceSet: [[1,4,9,10], [1,1,4,5], [1,1,2,4], [1,1,4,9], [1,2,5,10]])
    }
    
    static var F: Piece {
        /*
         FFF
         F
         F
         */
        return Piece(identifier: "F", ballCount: 5, maxLength: 8, distanceSet: [[1,4,5,8], [1,1,2,5], [1,1,4,4]])
    }
    
    static var S: Piece {
        /*
          S
          S
         SS
         S
         */
        return Piece(identifier: "S", ballCount: 5, maxLength: 10, distanceSet: [[1,4,5,10], [1,1,2,5], [1,1,2,4], [1,1,2,5], [1,2,5,10]])
    }
    
    static var C: Piece {
        /* Shape C
         CC
         C
         CC
         */
        return Piece(identifier: "C", ballCount: 5, maxLength: 5, distanceSet: [[1,2,4,5], [1,1,4,5], [1,1,2,2]])
    }
    
    static var W: Piece {
        /* Shape W
         WW
          WW
           WW
         */
        return Piece(identifier: "W", ballCount: 5, maxLength: 8, distanceSet: [[1,2,5,8], [1,1,2,5], [1,1,2,2]])
    }
    
    static var X: Piece {
        /* Shape X
          X
         XXX
          X
         */
        return Piece(identifier: "X", ballCount: 5, maxLength: 4, distanceSet: [[1,1,1,1], [1,2,2,4]])
    }
    
    static var B: Piece {
        /* Shape B
         B
         BB
         BB
         */
        return Piece(identifier: "B", ballCount: 5, maxLength: 5, distanceSet: [[1,2,4,5], [1,1,1,2], [1,1,2,2], [1,1,2,4], [1,1,2,5]])
    }
    
    static var Z: Piece {
        /* Zero
         ZZ
         ZZ
         */
        return Piece(identifier: "Z", ballCount: 4, maxLength: 2, distanceSet: [[1,1,2]])
    }
    
    static var O: Piece {
        /* One line
         OOOO
         */
        return Piece(identifier: "O", ballCount: 4, maxLength: 9, distanceSet: [[1,4,9], [1,1,4]])
    }
    
    static var Y: Piece {
        /* Shape Y
          Y
         YY
          Y
          Y
         */
        return Piece(identifier: "Y", ballCount: 5, maxLength: 9, distanceSet: [[1,2,4,9], [1,1,1,4], [1,2,2,5], [1,1,2,4], [1,4,5,9]])
    }
}

struct Game {
    var space = Array(repeating: Character(" "), count: 55)
    static let pieceCandidates: [Piece] = [Piece.H, Piece.L, Piece.U, Piece.F, Piece.S, Piece.C, Piece.W, Piece.X, Piece.B, Piece.Z, Piece.O, Piece.Y]
    var usePieceIndexes = IndexSet()
    static var DistanceTable: [Int] = {
        let str = "[0,1,4,9,16,1,2,5,10,17,4,5,8,13,20,9,10,13,18,25,16,17,20,25,32,1,3,7,13,3,5,9,15,7,9,13,19,13,15,19,25,4,7,12,7,10,15,12,15,20,9,13,13,17,16,1,0,1,4,9,2,1,2,5,10,5,4,5,8,13,10,9,10,13,18,17,16,17,20,25,1,1,3,7,3,3,5,9,7,7,9,13,13,13,15,19,3,4,7,6,7,10,11,12,15,7,9,11,13,13,4,1,0,1,4,5,2,1,2,5,8,5,4,5,8,13,10,9,10,13,20,17,16,17,20,3,1,1,3,5,3,3,5,9,7,7,9,15,13,13,15,4,3,4,7,6,7,12,11,12,7,7,11,11,12,9,4,1,0,1,10,5,2,1,2,13,8,5,4,5,18,13,10,9,10,25,20,17,16,17,7,3,1,1,9,5,3,3,13,9,7,7,19,15,13,13,7,4,3,10,7,6,15,12,11,9,7,13,11,13,16,9,4,1,0,17,10,5,2,1,20,13,8,5,4,25,18,13,10,9,32,25,20,17,16,13,7,3,1,15,9,5,3,19,13,9,7,25,19,15,13,12,7,4,15,10,7,20,15,12,13,9,17,13,16,1,2,5,10,17,0,1,4,9,16,1,2,5,10,17,4,5,8,13,20,9,10,13,18,25,1,3,7,13,1,3,7,13,3,5,9,15,7,9,13,19,3,6,11,4,7,12,7,10,15,7,11,9,13,13,2,1,2,5,10,1,0,1,4,9,2,1,2,5,10,5,4,5,8,13,10,9,10,13,18,1,1,3,7,1,1,3,7,3,3,5,9,7,7,9,13,2,3,6,3,4,7,6,7,10,5,7,7,9,10,5,2,1,2,5,4,1,0,1,4,5,2,1,2,5,8,5,4,5,8,13,10,9,10,13,3,1,1,3,3,1,1,3,5,3,3,5,9,7,7,9,3,2,3,4,3,4,7,6,7,5,5,7,7,9,10,5,2,1,2,9,4,1,0,1,10,5,2,1,2,13,8,5,4,5,18,13,10,9,10,7,3,1,1,7,3,1,1,9,5,3,3,13,9,7,7,6,3,2,7,4,3,10,7,6,7,5,9,7,10,17,10,5,2,1,16,9,4,1,0,17,10,5,2,1,20,13,8,5,4,25,18,13,10,9,13,7,3,1,13,7,3,1,15,9,5,3,19,13,9,7,11,6,3,12,7,4,15,10,7,11,7,13,9,13,4,5,8,13,20,1,2,5,10,17,0,1,4,9,16,1,2,5,10,17,4,5,8,13,20,3,5,9,15,1,3,7,13,1,3,7,13,3,5,9,15,4,7,12,3,6,11,4,7,12,7,11,7,11,12,5,4,5,8,13,2,1,2,5,10,1,0,1,4,9,2,1,2,5,10,5,4,5,8,13,3,3,5,9,1,1,3,7,1,1,3,7,3,3,5,9,3,4,7,2,3,6,3,4,7,5,7,5,7,9,8,5,4,5,8,5,2,1,2,5,4,1,0,1,4,5,2,1,2,5,8,5,4,5,8,5,3,3,5,3,1,1,3,3,1,1,3,5,3,3,5,4,3,4,3,2,3,4,3,4,5,5,5,5,8,13,8,5,4,5,10,5,2,1,2,9,4,1,0,1,10,5,2,1,2,13,8,5,4,5,9,5,3,3,7,3,1,1,7,3,1,1,9,5,3,3,7,4,3,6,3,2,7,4,3,7,5,7,5,9,20,13,8,5,4,17,10,5,2,1,16,9,4,1,0,17,10,5,2,1,20,13,8,5,4,15,9,5,3,13,7,3,1,13,7,3,1,15,9,5,3,12,7,4,11,6,3,12,7,4,11,7,11,7,12,9,10,13,18,25,4,5,8,13,20,1,2,5,10,17,0,1,4,9,16,1,2,5,10,17,7,9,13,19,3,5,9,15,1,3,7,13,1,3,7,13,7,10,15,4,7,12,3,6,11,9,13,7,11,13,10,9,10,13,18,5,4,5,8,13,2,1,2,5,10,1,0,1,4,9,2,1,2,5,10,7,7,9,13,3,3,5,9,1,1,3,7,1,1,3,7,6,7,10,3,4,7,2,3,6,7,9,5,7,10,13,10,9,10,13,8,5,4,5,8,5,2,1,2,5,4,1,0,1,4,5,2,1,2,5,9,7,7,9,5,3,3,5,3,1,1,3,3,1,1,3,7,6,7,4,3,4,3,2,3,7,7,5,5,9,18,13,10,9,10,13,8,5,4,5,10,5,2,1,2,9,4,1,0,1,10,5,2,1,2,13,9,7,7,9,5,3,3,7,3,1,1,7,3,1,1,10,7,6,7,4,3,6,3,2,9,7,7,5,10,25,18,13,10,9,20,13,8,5,4,17,10,5,2,1,16,9,4,1,0,17,10,5,2,1,19,13,9,7,15,9,5,3,13,7,3,1,13,7,3,1,15,10,7,12,7,4,11,6,3,13,9,11,7,13,16,17,20,25,32,9,10,13,18,25,4,5,8,13,20,1,2,5,10,17,0,1,4,9,16,13,15,19,25,7,9,13,19,3,5,9,15,1,3,7,13,12,15,20,7,10,15,4,7,12,13,17,9,13,16,17,16,17,20,25,10,9,10,13,18,5,4,5,8,13,2,1,2,5,10,1,0,1,4,9,13,13,15,19,7,7,9,13,3,3,5,9,1,1,3,7,11,12,15,6,7,10,3,4,7,11,13,7,9,13,20,17,16,17,20,13,10,9,10,13,8,5,4,5,8,5,2,1,2,5,4,1,0,1,4,15,13,13,15,9,7,7,9,5,3,3,5,3,1,1,3,12,11,12,7,6,7,4,3,4,11,11,7,7,12,25,20,17,16,17,18,13,10,9,10,13,8,5,4,5,10,5,2,1,2,9,4,1,0,1,19,15,13,13,13,9,7,7,9,5,3,3,7,3,1,1,15,12,11,10,7,6,7,4,3,13,11,9,7,13,32,25,20,17,16,25,18,13,10,9,20,13,8,5,4,17,10,5,2,1,16,9,4,1,0,25,19,15,13,19,13,9,7,15,9,5,3,13,7,3,1,20,15,12,15,10,7,12,7,4,17,13,13,9,16,1,1,3,7,13,1,1,3,7,13,3,3,5,9,15,7,7,9,13,19,13,13,15,19,25,0,1,4,9,1,2,5,10,4,5,8,13,9,10,13,18,1,3,7,3,5,9,7,9,13,4,7,7,10,9,3,1,1,3,7,3,1,1,3,7,5,3,3,5,9,9,7,7,9,13,15,13,13,15,19,1,0,1,4,2,1,2,5,5,4,5,8,10,9,10,13,1,1,3,3,3,5,7,7,9,3,4,6,7,7,7,3,1,1,3,7,3,1,1,3,9,5,3,3,5,13,9,7,7,9,19,15,13,13,15,4,1,0,1,5,2,1,2,8,5,4,5,13,10,9,10,3,1,1,5,3,3,9,7,7,4,3,7,6,7,13,7,3,1,1,13,7,3,1,1,15,9,5,3,3,19,13,9,7,7,25,19,15,13,13,9,4,1,0,10,5,2,1,13,8,5,4,18,13,10,9,7,3,1,9,5,3,13,9,7,7,4,10,7,9,3,3,5,9,15,1,1,3,7,13,1,1,3,7,13,3,3,5,9,15,7,7,9,13,19,1,2,5,10,0,1,4,9,1,2,5,10,4,5,8,13,1,3,7,1,3,7,3,5,9,3,6,4,7,7,5,3,3,5,9,3,1,1,3,7,3,1,1,3,7,5,3,3,5,9,9,7,7,9,13,2,1,2,5,1,0,1,4,2,1,2,5,5,4,5,8,1,1,3,1,1,3,3,3,5,2,3,3,4,5,9,5,3,3,5,7,3,1,1,3,7,3,1,1,3,9,5,3,3,5,13,9,7,7,9,5,2,1,2,4,1,0,1,5,2,1,2,8,5,4,5,3,1,1,3,1,1,5,3,3,3,2,4,3,5,15,9,5,3,3,13,7,3,1,1,13,7,3,1,1,15,9,5,3,3,19,13,9,7,7,10,5,2,1,9,4,1,0,10,5,2,1,13,8,5,4,7,3,1,7,3,1,9,5,3,6,3,7,4,7,7,7,9,13,19,3,3,5,9,15,1,1,3,7,13,1,1,3,7,13,3,3,5,9,15,4,5,8,13,1,2,5,10,0,1,4,9,1,2,5,10,3,5,9,1,3,7,1,3,7,4,7,3,6,7,9,7,7,9,13,5,3,3,5,9,3,1,1,3,7,3,1,1,3,7,5,3,3,5,9,5,4,5,8,2,1,2,5,1,0,1,4,2,1,2,5,3,3,5,1,1,3,1,1,3,3,4,2,3,5,13,9,7,7,9,9,5,3,3,5,7,3,1,1,3,7,3,1,1,3,9,5,3,3,5,8,5,4,5,5,2,1,2,4,1,0,1,5,2,1,2,5,3,3,3,1,1,3,1,1,4,3,3,2,5,19,13,9,7,7,15,9,5,3,3,13,7,3,1,1,13,7,3,1,1,15,9,5,3,3,13,8,5,4,10,5,2,1,9,4,1,0,10,5,2,1,9,5,3,7,3,1,7,3,1,7,4,6,3,7,13,13,15,19,25,7,7,9,13,19,3,3,5,9,15,1,1,3,7,13,1,1,3,7,13,9,10,13,18,4,5,8,13,1,2,5,10,0,1,4,9,7,9,13,3,5,9,1,3,7,7,10,4,7,9,15,13,13,15,19,9,7,7,9,13,5,3,3,5,9,3,1,1,3,7,3,1,1,3,7,10,9,10,13,5,4,5,8,2,1,2,5,1,0,1,4,7,7,9,3,3,5,1,1,3,6,7,3,4,7,19,15,13,13,15,13,9,7,7,9,9,5,3,3,5,7,3,1,1,3,7,3,1,1,3,13,10,9,10,8,5,4,5,5,2,1,2,4,1,0,1,9,7,7,5,3,3,3,1,1,7,6,4,3,7,25,19,15,13,13,19,13,9,7,7,15,9,5,3,3,13,7,3,1,1,13,7,3,1,1,18,13,10,9,13,8,5,4,10,5,2,1,9,4,1,0,13,9,7,9,5,3,7,3,1,10,7,7,4,9,4,3,4,7,12,3,2,3,6,11,4,3,4,7,12,7,6,7,10,15,12,11,12,15,20,1,1,3,7,1,1,3,7,3,3,5,9,7,7,9,13,0,1,4,1,2,5,4,5,8,1,3,3,5,4,7,4,3,4,7,6,3,2,3,6,7,4,3,4,7,10,7,6,7,10,15,12,11,12,15,3,1,1,3,3,1,1,3,5,3,3,5,9,7,7,9,1,0,1,2,1,2,5,4,5,1,1,3,3,3,12,7,4,3,4,11,6,3,2,3,12,7,4,3,4,15,10,7,6,7,20,15,12,11,12,7,3,1,1,7,3,1,1,9,5,3,3,13,9,7,7,4,1,0,5,2,1,8,5,4,3,1,5,3,4,7,6,7,10,15,4,3,4,7,12,3,2,3,6,11,4,3,4,7,12,7,6,7,10,15,3,3,5,9,1,1,3,7,1,1,3,7,3,3,5,9,1,2,5,0,1,4,1,2,5,1,3,1,3,3,10,7,6,7,10,7,4,3,4,7,6,3,2,3,6,7,4,3,4,7,10,7,6,7,10,5,3,3,5,3,1,1,3,3,1,1,3,5,3,3,5,2,1,2,1,0,1,2,1,2,1,1,1,1,2,15,10,7,6,7,12,7,4,3,4,11,6,3,2,3,12,7,4,3,4,15,10,7,6,7,9,5,3,3,7,3,1,1,7,3,1,1,9,5,3,3,5,2,1,4,1,0,5,2,1,3,1,3,1,3,12,11,12,15,20,7,6,7,10,15,4,3,4,7,12,3,2,3,6,11,4,3,4,7,12,7,7,9,13,3,3,5,9,1,1,3,7,1,1,3,7,4,5,8,1,2,5,0,1,4,3,5,1,3,4,15,12,11,12,15,10,7,6,7,10,7,4,3,4,7,6,3,2,3,6,7,4,3,4,7,9,7,7,9,5,3,3,5,3,1,1,3,3,1,1,3,5,4,5,2,1,2,1,0,1,3,3,1,1,3,20,15,12,11,12,15,10,7,6,7,12,7,4,3,4,11,6,3,2,3,12,7,4,3,4,13,9,7,7,9,5,3,3,7,3,1,1,7,3,1,1,8,5,4,5,2,1,4,1,0,5,3,3,1,4,9,7,7,9,13,7,5,5,7,11,7,5,5,7,11,9,7,7,9,13,13,11,11,13,17,4,3,4,7,3,2,3,6,4,3,4,7,7,6,7,10,1,1,3,1,1,3,3,3,5,0,1,1,2,1,13,9,7,7,9,11,7,5,5,7,11,7,5,5,7,13,9,7,7,9,17,13,11,11,13,7,4,3,4,6,3,2,3,7,4,3,4,10,7,6,7,3,1,1,3,1,1,5,3,3,1,0,2,1,1,13,11,11,13,17,9,7,7,9,13,7,5,5,7,11,7,5,5,7,11,9,7,7,9,13,7,6,7,10,4,3,4,7,3,2,3,6,4,3,4,7,3,3,5,1,1,3,1,1,3,1,2,0,1,1,17,13,11,11,13,13,9,7,7,9,11,7,5,5,7,11,7,5,5,7,13,9,7,7,9,10,7,6,7,7,4,3,4,6,3,2,3,7,4,3,4,5,3,3,3,1,1,3,1,1,2,1,1,0,1,16,13,12,13,16,13,10,9,10,13,12,9,8,9,12,13,10,9,10,13,16,13,12,13,16,9,7,7,9,7,5,5,7,7,5,5,7,9,7,7,9,4,3,4,3,2,3,4,3,4,1,1,1,1,0]"
        let data = str.data(using: .utf8)!
        let list = try? JSONSerialization.jsonObject(with: data, options: []) as? [Int]
        return list ?? []
    }()
    
    static private func distance(from: Int, to: Int) -> Int {
        return Game.DistanceTable[from * 55 + to]
    }
    
    private var mostDifficultPosition: PointInt3D? {
        func neighbors(pos: PointInt3D) -> Int {
            var score = 0
            var p = PointInt3D(x: 0, y: 0, z: 0)
            //4 neighbors in lower level
            p.z = pos.z - 1
            for x in pos.x...pos.x + 1 {
                p.x = x
                for y in pos.y...pos.y + 1 {
                    p.y = y
                    let index = p.index(outOfBoundAllowed: true)
                    if 0...54 ~= index {
                        score += space[index] == " " ? 0 : 1
                    } else {
                        score += 1
                    }
                }
            }
            //4 neighbors in upper level
            p.z = pos.z + 1
            for x in pos.x - 1...pos.x {
                p.x = x
                for y in pos.y - 1...pos.y {
                    p.y = y
                    let index = p.index(outOfBoundAllowed: true)
                    if 0...54 ~= index {
                        score += space[index] == " " ? 0 : 1
                    } else {
                        score += 1
                    }
                }
            }
            //4 neighbors in same level
            p.z = pos.z
            for x in pos.x - 1...pos.x + 1 {
                p.x = x
                for y in pos.y - 1...pos.y + 1 where x != pos.x || y != pos.y {
                    p.y = y
                    let index = p.index(outOfBoundAllowed: true)
                    if 0...54 ~= index {
                        score += space[index] == " " ? 0 : 1
                    } else {
                        score += 1
                    }
                }
            }
            
            return score
        }
        
        var maxDifficultLevel = 0
        var savePos: PointInt3D?
        var lp = savePos
        repeat {
            if let np = nextEmptyPosition(from: lp) {
                if space[np.index()] == " " {
                    let level = neighbors(pos: np)
                    if level > maxDifficultLevel {
                        maxDifficultLevel = level
                        savePos = np
                    }
                }
                lp = np
            } else {
                break
            }
        } while true
        
        return savePos
    }
    
    private func nextEmptyIndex(from lastIndex: Int?) -> Int? {
        if let li = lastIndex, li >= 54 {return nil}
        for i in ((lastIndex ?? -1) + 1)...54 where space[i] == " " {
            return i
        }
        return nil
    }
    
    private func nextEmptyPosition(from lastPoint: PointInt3D? = nil) -> PointInt3D? {
        let lastIndex = lastPoint?.index()
        let pnextIndex = nextEmptyIndex(from: lastIndex)
        if let nextIndex = pnextIndex {
            return PointInt3D.point(from: nextIndex)
        }
        return nil
    }
    
    private func isSameZ(pointList: [PointInt3D]) -> Bool {
        var lastZ: Int?
        for p in pointList {
            if let lz = lastZ {
                if lz != p.z {return false}
            } else {
                lastZ = p.z
            }
        }
        return true
    }
    
    private func isSamePlaneVertically(indexList: [Int]) -> Bool {
        var plusValue: Int?
        var minusValue: Int?
        var hasMultiplePlusValue = false
        var hasMultpleMinusValue = false
        for index in indexList {
            let p = PointInt3D.point(from: index)
            let plus = p.x + p.y + p.z
            let minus = p.x - p.y
            if let pv = plusValue, let mv = minusValue {
                if pv != plus {
                    hasMultiplePlusValue = true
                }
                if mv != minus {
                    hasMultpleMinusValue = true
                }
            } else {
                plusValue = plus
                minusValue = minus
            }
            if hasMultpleMinusValue && hasMultiplePlusValue {
                return false
            }
        }
        return true
    }
    
    private mutating func getNextEmptyPointIndexList(list: inout [Int], piece: Piece) -> Bool {
        var lastIndex = -1
        if list.count == piece.ballCount {
            let li = list.removeLast()
            space[li] = " "
            lastIndex = li
        } else if list.count == 0 {
            guard let firstIndex = nextEmptyIndex(from: nil) else {return false}
            list.append(firstIndex)
            lastIndex = firstIndex
        }
        while list.count < piece.ballCount {
            var pindex: Int?
            for i in lastIndex...54 where i > lastIndex && space[i] == " " {
                pindex = i
                break
            }
            guard let index = pindex else {
                if list.count == 1 {return false}
                lastIndex = list.removeLast()
                space[lastIndex] = " "
                continue
            }
            //make sure piece maxLength is complied
            var complied = true
            for i in list {
                if Game.distance(from: index, to: i) > piece.maxLength {
                    complied = false
                    break
                }
            }
            if complied {
                list.append(index)
                space[index] = piece.identifier
            }
            lastIndex = index
        }
        return true
    }
    
    func checkError() {
        var map = [Character: Int]()
        for i in 0...54 {
            let char = space[i]
            if let n = map[char] {
                map[char] = n + 1
            } else {
                map[char] = 1
            }
        }
        for i in 0..<Game.pieceCandidates.count {
            let piece = Game.pieceCandidates[i]
            if usePieceIndexes.contains(i) {
                assert(map[piece.identifier] == piece.ballCount, "piece \(piece.identifier) ball count is \(map[piece.identifier] ?? 0), but should be \(piece.ballCount)")
            } else {
                assert((map[piece.identifier] ?? 0) == 0, "Piece \(piece.identifier) not used, but board has at least one of its balls")
            }
        }
    }
    
    private func pointList(from indexList: [Int]) -> [PointInt3D] {
        return indexList.map{PointInt3D.point(from: $0)}
    }
    
    private func spawnFromNextPoint() -> [Game] {
        var result = [] as [Game]
        var newGame = self
        guard let firstPoint = mostDifficultPosition else {
            NSLog("Success")
            print(self)
            return []
        }
        let firstIndex = firstPoint.index()
        for i in 0..<Game.pieceCandidates.count where !usePieceIndexes.contains(i) {
            let piece = Game.pieceCandidates[i]
            newGame.space[firstPoint.index()] = piece.identifier
            var indexList = [firstIndex]
            while newGame.getNextEmptyPointIndexList(list: &indexList, piece: piece) {
                assert(indexList.count == piece.ballCount)
                
                //check if all points belong to a same plane
                let pointList = pointList(from: indexList)
                if (isSameZ(pointList: pointList) || isSamePlaneVertically(indexList: indexList))
                    && piece.isValidPoints(indexList: indexList)
                {
                    newGame.usePieceIndexes.insert(i)
                    result.append(newGame)
                    newGame.usePieceIndexes.remove(i)
                }
                
                
            }
        }
        return result
    }
    
    static func start(_ strInitialBoard: String) {
        var game = Game()
        var usePieces = Set<Character>()
        for i in 0..<strInitialBoard.count {
            let char = strInitialBoard[strInitialBoard.index(strInitialBoard.startIndex, offsetBy: i)]
            if char != " " {
                game.space[i] = char
                usePieces.insert(char)
            }
        }
        
        for i in 0..<Game.pieceCandidates.count {
            let id = Game.pieceCandidates[i].identifier
            if usePieces.contains(id) {
                game.usePieceIndexes.insert(i)
            }
        }
        game.checkError()
        game.start()
    }
    
    func start() {
        NSLog("Start")
        var list = [self]
        var nextList = [] as [Game]
        while !list.isEmpty {
            for game in list {
                nextList.append(contentsOf: game.spawnFromNextPoint())
            }
            list = nextList
            nextList = []
            NSLog("%ld", list.count)
        }
    }
}

extension Game: CustomDebugStringConvertible {
    var debugDescription: String {
        var stringList = Array(repeating: "", count: 5)
        for z in 0...4 {
            for y in 0...4 - z {
                if stringList[y].isEmpty {stringList[y] = "\(y)) "}
                for x in 0...4 - z {
                    stringList[y] += String(space[PointInt3D(x: x, y: y, z: z).index()])
                }
                stringList[y] += " | "
            }
        }
        let numberSum = stringList.reduce("", { x, y in
            x + y + "\n"
        })
        return numberSum
    }
}

extension Int {
    func distance(from index: Int) -> Int {
        return Game.DistanceTable[self * 55 + index]
    }
}
