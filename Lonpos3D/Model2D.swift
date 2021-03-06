//
//  Model2D.swift
//  Model2D
//
//  Created by Wei Dong on 2021-08-29.
//

import Foundation

struct Point2d: Hashable {
    var x, y: Int
    
    var index: Int {
        if y == 0 {
            return 0
        }
        var total = 0
        for i in 1...y {
            total += i
        }
        if total + x < 0 || total + x > 54 {
            abort()
        }
        return total + x
    }
    
    var leftPoint: Point2d {
        return Point2d(x: x - 1, y: y)
    }
    
    var rightPoint: Point2d {
        return Point2d(x: x + 1, y: y)
    }
    
    var topPoint: Point2d {
        return Point2d(x: x, y: y - 1)
    }
    
    var bottomPoint: Point2d {
        return Point2d(x: x, y: y + 1)
    }
}

extension Point2d: CustomStringConvertible {
    var description: String {
        "(\(x),\(y))"
    }
}

struct Game2d: IGame {
    var space = Array(repeating: Character(" "), count: 55)
    var usePieceIndexes = IndexSet()
    
    init(_ rawString: String) throws {
        var usePieces = Set<Character>()
        let string = rawString.uppercased().replacingOccurrences(of: ".", with: " ")
        if string.contains(",") {
            var line = 0
            for str in string.split(separator: ",", omittingEmptySubsequences: false) {
                assert(str.count <= line + 1)
                for col in 0..<str.count {
                    let char = str[str.index(str.startIndex, offsetBy: col)]
                    usePieces.insert(char)
                    let point = Point2d(x: col, y: line)
                    space[point.index] = char
                }
                line += 1
            }
        } else {
            for i in 0..<string.count {
                let char = string[string.index(string.startIndex, offsetBy: i)]
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
            if !piece.isValidPoints(indexList: list, distanceTable: Game2d.DistanceTable) {
                return "Distance from every 2 balls from piece '\(piece.identifier)' are not correct: \(list)"
            }
        }
        return nil
    }
    
    static func rowColumn(index : Int) -> Point2d {
        var total = 0
        for i in 1...10 {
            total = total + i
            if index < total {
                return Point2d(x: i - total + index, y: i - 1)
            }
        }
        abort()
    }
    
    func point3d(from index: Int) -> PointInt3D {
        let p2d = Game2d.rowColumn(index: index)
        return PointInt3D(x: p2d.x, y: p2d.y, z: 0)
    }
    
    static var DistanceTable: [Int] = {
        guard let path = Bundle.main.path(forResource: "lonpos2d_distance", ofType: "plist") else {abort()}
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {abort()}
        return (try? PropertyListDecoder().decode([Int].self, from: data)) ?? []
    }()
    
    static private func distance(from: Int, to: Int) -> Int {
        return Game2d.DistanceTable[from * 55 + to]
    }
    
    private func nextEmptyIndex(from lastIndex: Int?) -> Int? {
        if let li = lastIndex, li >= 54 {return nil}
        for i in ((lastIndex ?? -1) + 1)...54 where space[i] == " " {
            return i
        }
        return nil
    }
    
    func isValidList(list: [Int]) -> Bool {
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
                if Game2d.distance(from: index, to: i) > piece.maxLength {
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
    
    var mostDifficultIndex: Int? {
        var max = -1
        var result: Int?
        for i in 0...54 where space[i] == " " {
            var level = 0
            let p = Game2d.rowColumn(index: i)
            if p.x == 0 {
                level += 1
            } else if space[p.leftPoint.index] != " " {
                level += 1
            }
            if p.x == p.y || p.x + 1 > p.y {
                level += 1
            } else if space[p.rightPoint.index] != " " {
                level += 1
            }
            if p.y == 0 || p.x > p.y - 1 {
                level += 1
            } else if space[p.topPoint.index] != " " {
                level += 1
            }
            if p.y == 9 {
                level += 1
            } else if space[p.bottomPoint.index] != " " {
                level += 1
            }
            
            if level > max {
                max = level
                result = i
            }
        }
        return result
    }
}

extension Game2d: CustomStringConvertible {
    var description: String {
        var result = ""
        var i = 0
        for line in 0...9 {
            for _ in 0...line {
                result += String(space[i])
                i += 1
            }
            result += "\n"
        }
        return result + "---------"
    }
}
