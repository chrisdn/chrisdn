//
//  Model2D.swift
//  Model2D
//
//  Created by Wei Dong on 2021-08-29.
//

import Foundation

struct Point2d {
    var x, y: Int
    
    var index: Int {
        if y == 0 {
            return 0
        }
        var total = 0
        for i in 1...y {
            total += i
        }
        return total + x
    }
}

struct Game2d {
    private var space = Array(repeating: Character(" "), count: 55)
    private var usePieceIndexes = IndexSet()
    
    init(_ rawString: String) throws {
        var usePieces = Set<Character>()
        let string = rawString.uppercased().replacingOccurrences(of: ".", with: " ")
        if string.contains(",") {
            var line = 0
            for str in string.split(separator: ",") {
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
    
    static private var DistanceTable: [Int] = {
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
    
    private func mostDifficultIndex() -> Int? {
        for i in 0...54 {
            if space[i] == " " {
                return i
            }
        }
        return nil
    }
    
    private func spawnFromNextPoint() -> [Self] {
        var result = [] as [Game2d]
        guard let firstIndex = mostDifficultIndex() else {
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
                if piece.isValidPoints(indexList: indexList, distanceTable: Game2d.DistanceTable)
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
        var list = [self]
        var nextList = [] as [Game2d]
        while !list.isEmpty {
            for game in list {
                nextList.append(contentsOf: game.spawnFromNextPoint())
            }
            list = nextList
            nextList = []
            NSLog("%ld: %ld", level, list.count)
            level += 1
        }
        print("game2d done")
        NotificationQueue.default.enqueue(Notification(name: Game.notificationName, object: nil, userInfo: nil), postingStyle: .now)
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
