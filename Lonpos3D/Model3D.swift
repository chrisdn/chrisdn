//
//  Model3D.swift
//  Model3D
//
//  Created by Wei Dong on 2021-09-02.
//

import Foundation

struct Game3d: IGame {
    var space = Array(repeating: Character(" "), count: 55)
    var usePieceIndexes = IndexSet()
    static var DistanceTable: [Int] = {
        guard let path = Bundle.main.path(forResource: "lonpos3d_distance", ofType: "plist") else {abort()}
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {abort()}
        return (try? PropertyListDecoder().decode([Int].self, from: data)) ?? []
    }()
    
    var mostDifficultIndex: Int? {
        mostDifficultPosition?.index()
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
    
    func point3d(from index: Int) -> PointInt3D {
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
            return point3d(from: nextIndex)
        }
        return nil
    }
    
    func isValidList(list: [Int]) -> Bool {
        return isSameZ(indexList: list) || isSamePlaneVertically(indexList: list)
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
            let p = point3d(from: index)
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
    
    mutating func getNextEmptyPointIndexList(list: inout [Int], piece: Piece) -> Bool {
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
                if Self.DistanceTable[index * 55 + i] > piece.maxLength {
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
            if !piece.isValidPoints(indexList: list, distanceTable: Game3d.DistanceTable) {
                return "Distance from every 2 balls from piece '\(piece.identifier)' are not correct: \(list)"
            }
        }
        return nil
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
}

extension Game3d: CustomDebugStringConvertible {
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
