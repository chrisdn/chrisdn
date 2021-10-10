//
//  Wooduku.swift
//  Lonpos3D
//
//  Created by Wei Dong on 2021-09-17.
//

import Foundation

struct Woodoku {
    enum PieceType: String, CaseIterable {
        case dot = "1|0-1"
        
        case hline2 = "22|2-5", vline2 = "2,2|6-9"
        case sline2 = "1,.1|10-13", sline2_1 = ".1,1|14-17"
        
        case hline3 = "333|18-20", vline3 = "3,3,3|21-23"
        case sline3 = "1,.1,..1|24-26", sline3_1 = "..1,.1,1|27-29"
        case a1 = "22,1|30-35", a2 = "22,.1|36-41", a3 = "1,22|42-47", a4 = ".1,22|48-53"
        
        case hline4 = "4444|54-58", vline4 = "4,4,4,4|59-63"
        case sline4 = "1,.1,..1,...1|64-65", sline4_1 = "...1,..1,.1,1|66-67"
        case l1 = "333,1|68-69", l2 = "333,..1|70-71", l3 = "22,1,1|72-73", l4 = "22,.1,.1|74-75", l5 = "..1,333|76-77", l6 = "1,333|78-79", l7 = "1,1,22|80-81", l8 = ".1,.1,22|82-83"
        case tian = "22,22|84-95"
        case st1 = "333,.1|96-99", st2 = "1,22,1|100-103", st3 = ".1,333|104-107", st4 = ".1,22,.1|108-111"
        case s1 = "1,22,.1|112-115", s2 = ".22,22|116-119", s3 = ".1,22,1|120-123", s4 = "22,.22|124-127"
        
        case hline5 = "55555|128-135", vline5 = "5,5,5,5,5|136-143"
        case t1 = "333,.1.,.1.|144-147", t2 = "..1,333,..1|148-151", t3 = ".1.,.1.,333|152-155", t4 = "1,333,1|156-159"
        case c1 = "333,2 2|160-162", c2 = "22,2 ,22|163-165", c3 = "2 2,333|166-168", c4 = "22, 2,22|169-171"
        case x = ".1.,333,.1.|172-183"
        case f1 = "333,..1,..1|184-189", f2 = "333,1,1|190-195", f3 = "1,1,333|196-201", f4 = "..1,..1,333|202-207"
        
        var piece: Piece {
            return Piece(rawValue)
        }
    }
    struct Piece: Hashable {
        let pattern: [[Bool]]
        var xLength = 0
        var yLength = 0
        var ballCount = 0
        
        init(_ str: String) {
            guard let delimiter = str.firstIndex(of: "|") else {abort()}
            let string = str[..<delimiter]
            var list = [[Bool]]()
            for strLine in string.split(separator: ",", omittingEmptySubsequences: false) {
                var boolLine = [Bool]()
                for char in Array(strLine) {
                    let b = char != " " && char != "."
                    boolLine.append(b)
                    if b {ballCount += 1}
                }
                list.append(boolLine)
                xLength = max(xLength, boolLine.count)
            }
            pattern = list
            yLength = pattern.count
        }
        
        static func == (lhs: Piece, rhs: Piece) -> Bool {
                return lhs.pattern == rhs.pattern
            }

        func hash(into hasher: inout Hasher) {
            hasher.combine(pattern)
        }
    }
    
    struct PieceWithPosition: CustomStringConvertible {
        var description: String {
            "\(piece), \(pos)"
        }
        
        var piece: Piece
        var pos: Point2d
    }
    
    var board: [[Bool]]
    
    init(string: String) {
        var list = [[Bool]]()
        for strLine in string.split(separator: ",", omittingEmptySubsequences: false) {
            var boolLine = [Bool]()
            for char in Array(strLine) {
                boolLine.append(char != " " && char != ".")
            }
            list.append(boolLine)
        }
        board = list
    }
    
    init(board: [[Bool]]) {
        self.board = board
    }
    
    init() {
        var list = [[Bool]]()
        for _ in 0...8 {
            var boolLine = [Bool]()
            for _ in 0...8 {
                boolLine.append(false)
            }
            list.append(boolLine)
        }
        board = list
    }
    
    private var weight: Double {
        Woodoku.pointListInBoard.filter {board[$0.y][$0.x]}.reduce(0.0) {
            let dx = $1.x - 4
            let dy = $1.y - 4
            let distance = sqrt(Double(dx * dx + dy * dy))
            return $0 + distance
        }
    }
    
    private var isolatedAreaCount: Int {
        var iac = 1
        var area = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        Woodoku.pointListInBoard.forEach { point in
            if board[point.y][point.x] == false && area[point.y][point.x] == 0 {
                occupy(point: point, iac: iac, area: &area, comparison: false)
                iac += 1
            }
        }
        return iac - 1
    }
    
    private var clusterCount: Int {
        var iac = 1
        var area = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        Woodoku.pointListInBoard.forEach { point in
            if board[point.y][point.x] == true && area[point.y][point.x] == 0 {
                occupy(point: point, iac: iac, area: &area, comparison: true)
                iac += 1
            }
        }
        return iac - 1
    }
    
    private var totalConnections: Int {
        return Woodoku.pointListInBoard.reduce(0) { total, p in
            guard board[p.y][p.x] else {return total}
            var score = 0
            if p.x > 0 {
                if board[p.y][p.x - 1] {score += 1}
            }
            if p.x < 8 {
                if board[p.y][p.x + 1] {score += 1}
            }
            if p.y > 0 {
                if board[p.y - 1][p.x] {score += 1}
            }
            if p.y < 8 {
                if board[p.y + 1][p.x] {score += 1}
            }
            return total + score
        }
    }
    
    private func occupy(point: Point2d, iac: Int, area: inout [[Int]], comparison: Bool) {
        area[point.y][point.x] = iac
        if point.y > 0 {
            let newPoint = point.topPoint
            if board[newPoint.y][newPoint.x] == comparison && area[newPoint.y][newPoint.x] == 0 {
                occupy(point: newPoint, iac: iac, area: &area, comparison: comparison)
            }
        }
        if point.y < 8 {
            let newPoint = point.bottomPoint
            if board[newPoint.y][newPoint.x] == comparison && area[newPoint.y][newPoint.x] == 0 {
                occupy(point: newPoint, iac: iac, area: &area, comparison: comparison)
            }
        }
        if point.x > 0 {
            let newPoint = point.leftPoint
            if board[newPoint.y][newPoint.x] == comparison && area[newPoint.y][newPoint.x] == 0 {
                occupy(point: newPoint, iac: iac, area: &area, comparison: comparison)
            }
        }
        if point.x < 8 {
            let newPoint = point.rightPoint
            if board[newPoint.y][newPoint.x] == comparison && area[newPoint.y][newPoint.x] == 0 {
                occupy(point: newPoint, iac: iac, area: &area, comparison: comparison)
            }
        }
    }
    
    mutating func trim() -> Int {
        var set: Set<Point2d> = []
        var allFilled: Bool
        var score = 0;
        
        //check hline
        for y in 0...8 {
            allFilled = true
            for x in 0...8 {
                if !board[y][x] {
                    allFilled = false
                    break
                }
            }
            if allFilled {
                score += 1
                for x in 0...8 {
                    set.insert(Point2d(x: x, y: y))
                }
            }
        }
        
        //check vline
        for x in 0...8 {
            allFilled = true
            for y in 0...8 {
                if !board[y][x] {
                    allFilled = false
                    break
                }
            }
            if allFilled {
                score += 1
                for y in 0...8 {
                    set.insert(Point2d(x: x, y: y))
                }
            }
        }
        
        //check 9block
        for x in 0...2 {
            for y in 0...2 {
                allFilled = true
            outer: for dx in 0...2 {
                    for dy in 0...2 {
                        if !board[y * 3 + dy][x * 3 + dx] {
                            allFilled = false
                            break outer
                        }
                    }
                }
                if allFilled {
                    score += 1
                    for dx in 0...2 {
                        for dy in 0...2 {
                            set.insert(Point2d(x: x * 3 + dx, y: y * 3 + dy))
                        }
                    }
                }
            }
        }
        
        for p in set {
            board[p.y][p.x] = false
        }
        
        switch score {
        case 0: return 0
        case 1: return 18
        default: return 18 + 28 * (score - 1)
        }
    }
    
    func place(piece: Piece, at point:Point2d) -> Woodoku? {
        var newGame = self
        for dy in 0..<piece.pattern.count {
            for dx in 0..<piece.pattern[dy].count where piece.pattern[dy][dx] {
                if board[point.y + dy][point.x + dx] {
                    return nil
                }
                newGame.board[point.y + dy][point.x + dx] = true
            }
        }
        return newGame
    }
    
    private static var pointListInBoard: [Point2d] = {
        var list = [Point2d]()
        for x in 0...8 {
            for y in 0...8 {
                list.append(Point2d(x: x, y: y))
            }
        }
        return list
    }()
    
    private static var combinationIndexes = [
        [[]],
        [[0]],
        [[0,0], [0,1], [1,0], [1,1]],
        [[0,1,2], [0,2,1], [1,0,2], [1,2,0], [2,0,1], [2,1,0]]
    ]
    
    func place(pieces: [Piece], checkFeasibility: Bool = false) -> ([PieceWithPosition]?, Woodoku?, Int) {
        func evaluate(score: Int, game: Woodoku, pieceAndPositions: PieceWithPosition...) {
            if score > bestScore {
                bestScore = score
                bestSolutions = [(pieceAndPositions, game)]
            } else if score == bestScore {
                if bestSolutions != nil {
                    bestSolutions?.append((pieceAndPositions, game))
                } else {
                    bestSolutions = [(pieceAndPositions, game)]
                }
            }
        }
        
        var history = [] as Set<Int>
        var bestSolutions: [([PieceWithPosition], Woodoku)]?
        var bestScore = 0
        for indexes in Woodoku.combinationIndexes[pieces.count] {
            let piece0 = pieces[indexes[0]]
            for p0 in Woodoku.pointListInBoard where p0.y + piece0.yLength <= 9 && p0.x + piece0.xLength <= 9 {
                if let ugame0 = place(piece: piece0, at: p0) {
                    let fingerPrint0 = ugame0.board.hashValue
                    if history.contains(fingerPrint0) {
                        continue
                    }
                    history.insert(fingerPrint0)
                    var game0 = ugame0
                    let score0 = game0.trim()
                    
                    if pieces.count == 1 {
                        evaluate(score: score0, game: game0, pieceAndPositions: PieceWithPosition(piece: piece0, pos: p0))
                        continue
                    }
                    let piece1 = pieces[indexes[1]]
                    for p1 in Woodoku.pointListInBoard where p1.y + piece1.yLength <= 9 && p1.x + piece1.xLength <= 9 {
                        if let ugame1 = game0.place(piece: piece1, at: p1) {
                            let fingerPrint1 = ugame1.board.hashValue
                            if history.contains(fingerPrint1) {
                                continue
                            }
                            history.insert(fingerPrint1)
                            var game1 = ugame1
                            let score1 = game1.trim()
                            
                            if pieces.count == 2 {
                                evaluate(score: score0 + score1, game: game1, pieceAndPositions: PieceWithPosition(piece: piece0, pos: p0), PieceWithPosition(piece: piece1, pos: p1)
                                )
                                continue
                            }
                            let piece2 = pieces[indexes[2]]
                            for p2 in Woodoku.pointListInBoard where p2.y + piece2.yLength <= 9 && p2.x + piece2.xLength <= 9 {
                                if let ugame2 = game1.place(piece: piece2, at: p2) {
                                    let fingerPrint2 = ugame2.board.hashValue
                                    if history.contains(fingerPrint2) {
                                        continue
                                    }
                                    history.insert(fingerPrint2)
                                    if checkFeasibility {
                                        return ([], nil, 0)
                                    }
                                    var game2 = ugame2
                                    let score2 = game2.trim()
                                    evaluate(score: score0 + score1 + score2, game: game2, pieceAndPositions: PieceWithPosition(piece: piece0, pos: p0), PieceWithPosition(piece: piece1, pos: p1), PieceWithPosition(piece: piece2, pos: p2)
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
        
        print("best score:", bestScore)
        guard let solutions = bestSolutions else {return (nil, nil, bestScore)}
        if solutions.count == 1 {
            return (solutions.first!.0, solutions.first!.1, bestScore)
        }
        print("solutions: \(solutions.count)")
        var bestIndexes = IndexSet()
        var maxConnections = 0
        for index in 0..<solutions.count {
            let connections = solutions[index].1.totalConnections
            if connections > maxConnections {
                maxConnections = connections
                bestIndexes.removeAll()
                bestIndexes.insert(index)
            } else if connections == maxConnections {
                bestIndexes.insert(index)
            }
        }
        guard bestIndexes.count > 1 else {
            let bestIndex = bestIndexes.first
            return (solutions[bestIndex!].0, solutions[bestIndex!].1, bestScore)
        }
        
        var lowestIac = 99999
        var bestIndex: Int?
        for index in bestIndexes {
            let iac = solutions[index].1.isolatedAreaCount
            if iac < lowestIac {
                lowestIac = iac
                bestIndex = index
            }
        }
        return (solutions[bestIndex!].0, solutions[bestIndex!].1, bestScore)
    }
}

extension Woodoku.Piece: CustomStringConvertible {
    var description: String {
        var result = "\n"
        for line in pattern {
            for b in line {
                result += b ? "x" : " "
            }
            result += "\n"
        }
        return result
    }
}

extension Woodoku: CustomStringConvertible {
    var description: String {
        var result = "\n-------------------\n"
        for line in board {
            result += "|"
            for b in line {
                result += b ? "x|" : " |"
            }
            result += "\n"
        }
        return result + "-------------------\n"
    }
}
