//
//  Wooduku.swift
//  Lonpos3D
//
//  Created by Wei Dong on 2021-09-17.
//

import Foundation

struct Woodoku {
    enum PieceType: String, CaseIterable {
        case hline5 = "55555", vline5 = "5,5,5,5,5", hline4 = "4444", vline4 = "4,4,4,4"
        case hline3 = "333", vline3 = "3,3,3", hline2 = "22", vline2 = "2,2"
        case c1 = "333,2 2", c2 = "22,2 ,22", c3 = "2 2,333", c4 = "22, 2,22"
        case x = ".1.,333,.1."
        case sline4 = "1,.1,..1,...1", sline4_1 = "...1,..1,.1,1"
        case sline3 = "1,.1,..1", sline3_1 = "..1,.1,1"
        case sline2 = "1,.1", sline2_1 = ".1,1"
        case l1 = "333,1", l2 = "333,..1", l3 = "22,1,1", l4 = "22,.1,.1"
        case l5 = "..1,333", l6 = "1,333", l7 = "1,1,22", l8 = ".1,.1,22"
        case s1 = "1,22,.1", s2 = ".22,22", s3 = ".1,22,1", s4 = "22,.22"
        case tian = "22,22", a1 = "22,1", a2 = "22,.1", a3 = "1,22", a4 = ".1,22"
        case t1 = "333,.1.,.1.", t2 = "..1,333,..1", t3 = ".1.,.1.,333", t4 = "1,333,1"
        case st1 = "333,.1", st2 = "1,22,1", st3 = ".1,333", st4 = ".1,22,.1"
        case f1 = "333,..1,..1", f2 = "333,1,1", f3 = "1,1,333", f4 = "..1,..1,333"
        case dot = "1"
        
        var piece: Piece {
            return Piece(string: rawValue)
        }
    }
    struct Piece {
        let pattern: [[Bool]]
        var xLength = 0
        var yLength = 0
        let input: String
        
        init(string: String) {
            input = string
            var list = [[Bool]]()
            for strLine in string.split(separator: ",", omittingEmptySubsequences: false) {
                var boolLine = [Bool]()
                for char in Array(strLine) {
                    boolLine.append(char != " " && char != ".")
                }
                list.append(boolLine)
                xLength = max(xLength, boolLine.count)
            }
            pattern = list
            yLength = pattern.count
        }
    }
    
    struct PieceWithPosition {
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
    
    var score: Float {
        var result:Float = 0
        for y in 0...8 {
            for x in 0...8 {
                result += board[y][x] ? 0 : 1
            }
        }
        
        //middle grid emptyness check
        for x in 3...5 {
            for y in 3...5 {
                if board[y][x] {
                    result -= 0.3
                }
            }
        }
        
        //isolated space check
        /*for x in 0...8 {
            for y in 0...8 where !board[y][x] {
                switch (x, y) {
                case (0,0):
                    if board[0][1] && board[1][0] {result -= 0.5}
                case (0,8):
                    if board[7][0] && board[8][1] {result -= 0.5}
                case (8,0):
                    if board[1][8] && board[0][7] {result -= 0.5}
                case (8,8):
                    if board[8][7] && board[7][8] {result -= 0.5}
                case (0,1...7):
                    if board[y - 1][x] && board[y + 1][x] && board[y][x + 1] {result -= 0.5}
                case (8,1...7):
                    if board[y - 1][x] && board[y + 1][x] && board[y][x - 1] {result -= 0.5}
                case (1...7,0):
                    if board[y][x - 1] && board[y][x + 1] && board[y + 1][x] {result -= 0.5}
                case (1...7,8):
                    if board[y][x - 1] && board[y][x + 1] && board[y - 1][x] {result -= 0.5}
                default:
                    if board[y - 1][x] && board[y + 1][x] && board[y][x - 1] && board[y][x + 1] {result -= 0.5}
                }
            }
        }*/
        
        //isolated area count
        var iac = 1
        var area = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        for x in 0...8 {
            for y in 0...8 where !board[y][x] && area[y][x] == 0 {
                area[y][x] = iac
                //expand to adjacent space
                occupy(x: x, y: y, iac: iac, area: &area)
                iac += 1
            }
        }
        
        result -= Float(iac - 1) * 0.3
        
        return result
    }
    
    private func occupy(x: Int, y: Int, iac: Int, area: inout [[Int]]) {
        area[y][x] = iac
        if y > 0 {
            if !board[y - 1][x] && area[y - 1][x] == 0 {
                occupy(x: x, y: y - 1, iac: iac, area: &area)
            }
        }
        if y < 8 {
            if !board[y + 1][x] && area[y + 1][x] == 0 {
                occupy(x: x, y: y + 1, iac: iac, area: &area)
            }
        }
        if x > 0 {
            if !board[y][x - 1] && area[y][x - 1] == 0 {
                occupy(x: x - 1, y: y, iac: iac, area: &area)
            }
        }
        if x < 8 {
            if !board[y][x + 1] && area[y][x + 1] == 0 {
                occupy(x: x + 1, y: y, iac: iac, area: &area)
            }
        }
    }
    
    mutating func trim() -> Bool {
        var set: Set<Point2d> = []
        var allFilled: Bool
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
        
        return !set.isEmpty
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
    
    func place(pieces: [Piece]) -> [PieceWithPosition]? {
        var history = [] as Set<String>
        var bestPiecePositions: [PieceWithPosition]?
        var bestScore = 0 as Float
        for indexes in [[0,1,2], [0,2,1], [1,0,2], [1,2,0], [2,0,1], [2,1,0]] {
            for y0 in 0...8 where y0 + pieces[indexes[0]].yLength <= 9 {
                for x0 in 0...8 where x0 + pieces[indexes[0]].xLength <= 9 {
                    if let ugame0 = place(piece: pieces[indexes[0]], at: Point2d(x: x0, y: y0)) {
                        var game0 = ugame0
                        let dirty0 = game0.trim()
                        let fingerPrint0 = pieces[indexes[0]].input + (dirty0 ? "d" : "s") + "\(x0),\(y0)"
                        if history.contains(fingerPrint0) {
                            continue
                        }
                        history.insert(fingerPrint0)
                        for y1 in 0...8 where y1 + pieces[indexes[1]].yLength <= 9 {
                            for x1 in 0...8 where x1 + pieces[indexes[1]].xLength <= 9 {
                                if let ugame1 = game0.place(piece: pieces[indexes[1]], at: Point2d(x: x1, y: y1)) {
                                    var game1 = ugame1
                                    let dirty1 = game1.trim()
                                    let fingerPrint1 = fingerPrint0 + ":" + pieces[indexes[1]].input + (dirty1 ? "d" : "s") + "\(x1),\(y1)"
                                    if history.contains(fingerPrint1) {
                                        continue
                                    }
                                    history.insert(fingerPrint1)
                                    for y2 in 0...8 where y2 + pieces[indexes[2]].yLength <= 9 {
                                        for x2 in 0...8 where x2 + pieces[indexes[2]].xLength <= 9 {
                                            if let ugame2 = game1.place(piece: pieces[indexes[2]], at: Point2d(x: x2, y: y2)) {
                                                var game2 = ugame2
                                                let dirty2 = game2.trim()
                                                let fingerPrint2 = fingerPrint1 + ":" + pieces[indexes[2]].input + (dirty2 ? "d" : "s") + "\(x2),\(y2)"
                                                if history.contains(fingerPrint2) {
                                                    continue
                                                }
                                                history.insert(fingerPrint2)
                                                let score = game2.score
                                                if score > bestScore {
                                                    bestScore = score
                                                    bestPiecePositions = [
                                                        PieceWithPosition(piece: pieces[indexes[0]], pos: Point2d(x: x0, y: y0)),
                                                        PieceWithPosition(piece: pieces[indexes[1]], pos: Point2d(x: x1, y: y1)),
                                                        PieceWithPosition(piece: pieces[indexes[2]], pos: Point2d(x: x2, y: y2))
                                                    ]
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return bestPiecePositions
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
        var result = "\n-----------\n"
        for line in board {
            result += "|"
            for b in line {
                result += b ? "x" : " "
            }
            result += "|\n"
        }
        return result + "-----------"
    }
}
