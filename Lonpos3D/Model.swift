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

struct Game {
    static let notificationName = Notification.Name(rawValue: "lonpos")
    var space = Array(repeating: Character(" "), count: 55)
    static let pieceCandidates: [Piece] = [Piece.H, Piece.L, Piece.U, Piece.F, Piece.S, Piece.C, Piece.W, Piece.X, Piece.B, Piece.Z, Piece.O, Piece.Y]
    var usePieceIndexes = IndexSet()
    static var DistanceTable: [Int] = {
        guard let path = Bundle.main.path(forResource: "lonpos3d_distance", ofType: "plist") else {abort()}
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {abort()}
        return (try? PropertyListDecoder().decode([Int].self, from: data)) ?? []
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
    
    private func isSameZ(indexList: [Int]) -> Bool {
        let threshHoldList: [Int] = [25, 25 + 16, 25 + 16 + 9, 25 + 16 + 9 + 4]
        var min: Int?
        for threshHold in threshHoldList {
            if (indexList.max() ?? 999) < threshHold  && (indexList.min() ?? -1) >= (min ?? 0) {return true}
            min =  threshHold
        }
        return false
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
    
    static func piece(with id: Character) -> Piece? {
        return Game.pieceCandidates.first{$0.identifier == id}
    }
    
    private func checkError() -> String? {
        var map = [Character: [Int]]()
        for i in 0...54 {
            let char = space[i]
            if let list = map[char] {
                map[char] = list + [i]
            } else {
                map[char] = [i]
            }
        }
        for (char, list) in map where char != " " {
            guard let piece = Game.piece(with: char) else {
                return "Unknown piece identifier '\(char)'"
            }
            if list.count != piece.ballCount {
                return "Piece '\(piece.identifier)' ball count is \(list.count), but should be \(piece.ballCount)"
            }
            if !isSameZ(indexList: list) && !isSamePlaneVertically(indexList: list) {
                return "Balls from piece '\(piece.identifier)' are not in same vertical plain, and not at same z level: \(list)"
            }
            if !piece.isValidPoints(indexList: list, distanceTable: Game.DistanceTable) {
                return "Distance from every 2 balls from piece '\(piece.identifier)' are not correct: \(list)"
            }
        }
        return nil
    }
    
    private func spawnFromNextPoint() -> [Game] {
        var result = [] as [Game]
        guard let firstPoint = mostDifficultPosition else {
            NSLog("Success")
            print(self)
            NotificationQueue.default.enqueue(Notification(name: Game.notificationName, object: self, userInfo: nil), postingStyle: .now)
            return []
        }
        let firstIndex = firstPoint.index()
        var newGame = self
        for i in 0..<Game.pieceCandidates.count where !usePieceIndexes.contains(i) {
            let piece = Game.pieceCandidates[i]
            newGame.space[firstIndex] = piece.identifier
            var indexList = [firstIndex]
            while newGame.getNextEmptyPointIndexList(list: &indexList, piece: piece) {
                assert(indexList.count == piece.ballCount)
                
                //check if all points belong to a same plane
                if (isSameZ(indexList: indexList) || isSamePlaneVertically(indexList: indexList))
                    && piece.isValidPoints(indexList: indexList, distanceTable: Game.DistanceTable)
                {
                    newGame.usePieceIndexes.insert(i)
                    result.append(newGame)
                    newGame.usePieceIndexes.remove(i)
                }
            }
        }
        return result
    }
    
    init(_ strList: [String]) throws {
        var usePieces = Set<Character>()
        for z in 0..<strList.count {
            var offset: Int
            switch z {
            case 0:
                offset = 0
            case 1:
                offset = 25
            case 2:
                offset = 25 + 16
            case 3:
                offset = 25 + 16 + 9
            case 4:
                offset = 25 + 16 + 9 + 4
            default:
                throw LonposError.inputError("Too many lines for lonpos 3d, max is 5")
            }
            for i in 0..<strList[z].count {
                let str = strList[z]
                let char = str[str.index(str.startIndex, offsetBy: i)]
                if char != " " {
                    space[offset + i] = char
                    usePieces.insert(char)
                }
            }
        }
        
        for i in 0..<Game.pieceCandidates.count {
            let id = Game.pieceCandidates[i].identifier
            if usePieces.contains(id) {
                usePieceIndexes.insert(i)
            }
        }
        if let msg = checkError() {
            throw LonposError.inputError(msg)
        }
    }
    
    init(_ strInitialBoard: String) throws {
        var usePieces = Set<Character>()
        for i in 0..<strInitialBoard.count {
            let char = strInitialBoard[strInitialBoard.index(strInitialBoard.startIndex, offsetBy: i)]
            if char != " " {
                space[i] = char
                usePieces.insert(char)
            }
        }
        
        for i in 0..<Game.pieceCandidates.count {
            let id = Game.pieceCandidates[i].identifier
            if usePieces.contains(id) {
                usePieceIndexes.insert(i)
            }
        }
        if let msg = checkError() {
            throw LonposError.inputError(msg)
        }
    }
    
    func start() {
        NSLog("Start")
        var level = 1
        var list = [self]
        var nextList = [] as [Game]
        while !list.isEmpty {
            for game in list {
                nextList.append(contentsOf: game.spawnFromNextPoint())
            }
            list = nextList
            nextList = []
            NSLog("%ld: %ld", level, list.count)
            level += 1
        }
        NotificationQueue.default.enqueue(Notification(name: Game.notificationName, object: nil, userInfo: nil), postingStyle: .now)
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

enum LonposError: Error {
    case inputError(String)
}
