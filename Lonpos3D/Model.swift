//
//  Model.swift
//  Model
//
//  Created by Wei Dong on 2021-08-25.
//

import Foundation
import AppKit

struct PointInt3D {
    var x, y, z: Int
    
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
    var color: NSColor
    
    func isValidPoints(indexList: [Int], distanceTable: [Int]) -> Bool {
        var tSet = Set<[Int]>()
        for i in 0..<indexList.count {
            let index0 = indexList[i]
            var list = [Int]()
            for j in 0..<indexList.count where i != j {
                let distance = distanceTable[index0 * 55 + indexList[j]]
                list.append(distance)
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
        return Piece(identifier: "H", ballCount: 3, maxLength: 2, distanceSet: [[1,2], [1,1]], color: .white)
    }
    
    static var L: Piece {
        /* Shape L
         L
         L
         LL
         */
        return Piece(identifier: "L", ballCount: 4, maxLength: 5, distanceSet: [[1,4,5], [1,1,2], [1,1,4], [1,2,5]], color: .orange)
    }
    
    static var U: Piece {
        /* Umbrella
         U
         U
         U
         UU
         */
        return Piece(identifier: "U", ballCount: 5, maxLength: 10, distanceSet: [[1,4,9,10], [1,1,4,5], [1,1,2,4], [1,1,4,9], [1,2,5,10]], color: NSColor(red: 0, green: CGFloat(36) / 255, blue: CGFloat(156) / 255, alpha: 1))
    }
    
    static var F: Piece {
        /*
         FFF
         F
         F
         */
        return Piece(identifier: "F", ballCount: 5, maxLength: 8, distanceSet: [[1,4,5,8], [1,1,2,5], [1,1,4,4]], color: NSColor(red: CGFloat(135) / 255, green: CGFloat(206) / 255, blue: 1, alpha: 1))
    }
    
    static var S: Piece {
        /*
          S
          S
         SS
         S
         */
        return Piece(identifier: "S", ballCount: 5, maxLength: 10, distanceSet: [[1,4,5,10], [1,1,2,5], [1,1,2,4], [1,1,2,5], [1,2,5,10]], color: NSColor(red: 0, green: CGFloat(100) / 255, blue: 0, alpha: 1))
    }
    
    static var C: Piece {
        /* Shape C
         CC
         C
         CC
         */
        return Piece(identifier: "C", ballCount: 5, maxLength: 5, distanceSet: [[1,2,4,5], [1,1,4,5], [1,1,2,2]], color: .yellow)
    }
    
    static var W: Piece {
        /* Shape W
         WW
          WW
           WW
         */
        return Piece(identifier: "W", ballCount: 5, maxLength: 8, distanceSet: [[1,2,5,8], [1,1,2,5], [1,1,2,2]], color: NSColor(red: CGFloat(214) / 255, green: CGFloat(37) / 255, blue: CGFloat(152) / 255, alpha: 1))
    }
    
    static var X: Piece {
        /* Shape X
          X
         XXX
          X
         */
        return Piece(identifier: "X", ballCount: 5, maxLength: 4, distanceSet: [[1,1,1,1], [1,2,2,4]], color: .gray)
    }
    
    static var B: Piece {
        /* Shape B
         B
         BB
         BB
         */
        return Piece(identifier: "B", ballCount: 5, maxLength: 5, distanceSet: [[1,2,4,5], [1,1,1,2], [1,1,2,2], [1,1,2,4], [1,1,2,5]], color: .red)
    }
    
    static var Z: Piece {
        /* Zero
         ZZ
         ZZ
         */
        return Piece(identifier: "Z", ballCount: 4, maxLength: 2, distanceSet: [[1,1,2]], color: .green)
    }
    
    static var O: Piece {
        /* One line
         OOOO
         */
        return Piece(identifier: "O", ballCount: 4, maxLength: 9, distanceSet: [[1,4,9], [1,1,4]], color: .purple)
    }
    
    static var Y: Piece {
        /* Shape Y
          Y
         YY
          Y
          Y
         */
        return Piece(identifier: "Y", ballCount: 5, maxLength: 9, distanceSet: [[1,2,4,9], [1,1,1,4], [1,2,2,5], [1,1,2,4], [1,4,5,9]], color: NSColor(red: 1, green: CGFloat(192) / 255, blue: CGFloat(203) / 255, alpha: 1))
    }
}

enum LonposError: Error {
    case inputError(String)
}

protocol IGame {
    var space: [Character] {get set}
    var usePieceIndexes: IndexSet {get set}
    var mostDifficultIndex:Int? {get}
    static var DistanceTable: [Int] {get}
    func isValidList(list: [Int]) -> Bool
    mutating func getNextEmptyPointIndexList(list: inout [Int], piece: Piece) -> Bool
}

extension IGame {
    private func spawn() -> [Self] {
        var result = [] as [Self]
        guard let firstIndex = mostDifficultIndex else {
            NSLog("Success")
            print(self)
            NotificationQueue.default.enqueue(Notification(name: Game.notificationName, object: self, userInfo: nil), postingStyle: .now)
            return []
        }
        var newGame = self
        for i in 0..<Game.pieceCandidates.count where !usePieceIndexes.contains(i) {
            let piece = Game.pieceCandidates[i]
            newGame.space[firstIndex] = piece.identifier
            var indexList = [firstIndex]
            while newGame.getNextEmptyPointIndexList(list: &indexList, piece: piece) {
                assert(indexList.count == piece.ballCount)
                
                //check if all points belong to a same plane
                if isValidList(list: indexList) && piece.isValidPoints(indexList: indexList, distanceTable: Self.DistanceTable)
                {
                    newGame.usePieceIndexes.insert(i)
                    result.append(newGame)
                    newGame.usePieceIndexes.remove(i)
                }
            }
        }
        return result
    }
    
    func start() {
        NSLog("Start")
        var level = 1
        var list = [self] as [IGame]
        var nextList = [IGame]()
        while !list.isEmpty {
            for game in list {
                nextList.append(contentsOf: game.spawn())
            }
            list = nextList
            nextList = []
            NSLog("%ld: %ld", level, list.count)
            level += 1
        }
        NotificationQueue.default.enqueue(Notification(name: Game.notificationName, object: nil, userInfo: nil), postingStyle: .now)
    }
}

struct Game {
    static let notificationName = Notification.Name(rawValue: "lonpos")
    static let pieceCandidates: [Piece] = [Piece.H, Piece.L, Piece.U, Piece.F, Piece.S, Piece.C, Piece.W, Piece.X, Piece.B, Piece.Z, Piece.O, Piece.Y]
    
    static func piece(with id: Character) -> Piece? {
        return Game.pieceCandidates.first{$0.identifier == id}
    }
}
