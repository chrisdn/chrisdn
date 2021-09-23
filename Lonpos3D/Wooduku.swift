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
        
        var piece: Piece {
            return Piece(string: rawValue)
        }
    }
    struct Piece {
        let pattern: [[Bool]]
        var xLength = 0
        var yLength = 0
        
        init(string: String) {
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
    
    var score: Int {
        var result = 0
        for y in 0...8 {
            for x in 0...8 {
                result += board[y][x] ? 0 : 1
            }
        }
        return result
    }
    
    mutating func trim() {
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
    }
    
    private static func place(piece: Piece, in game: Woodoku, at point:Point2d) -> Woodoku? {
        var newGame = Woodoku(board: game.board)
        for dy in 0..<piece.pattern.count {
            for dx in 0..<piece.pattern[dy].count where piece.pattern[dy][dx] {
                if game.board[point.y + dy][point.x + dx] {
                    return nil
                }
                newGame.board[point.y + dy][point.x + dx] = true
            }
        }
        return newGame
    }
    
    func place(pieces: [Piece]) -> [PieceWithPosition]? {
        print(self)
        var bestPiecePositions: [PieceWithPosition]?
        var bestScore = 0
        //first piece
        for y0 in 0...8 where y0 + pieces[0].yLength <= 9 {
            for x0 in 0...8 where x0 + pieces[0].xLength <= 9 {
                if let game0 = Woodoku.place(piece: pieces[0], in: self, at: Point2d(x: x0, y: y0)) {
                    for y1 in 0...8 where y1 + pieces[1].yLength <= 9 {
                        for x1 in 0...8 where x1 + pieces[1].xLength <= 9 {
                            if let game1 = Woodoku.place(piece: pieces[1], in: game0, at: Point2d(x: x1, y: y1)) {
                                for y2 in 0...8 where y2 + pieces[2].yLength <= 9 {
                                    for x2 in 0...8 where x2 + pieces[2].xLength <= 9 {
                                        if let game2 = Woodoku.place(piece: pieces[2], in: game1, at: Point2d(x: x2, y: y2)) {
                                            var gameAfterTrim = game2
                                            gameAfterTrim.trim()
                                            let score = gameAfterTrim.score
                                            if score > bestScore {
                                                bestScore = score
                                                bestPiecePositions = [
                                                    PieceWithPosition(piece: pieces[0], pos: Point2d(x: x0, y: y0)),
                                                    PieceWithPosition(piece: pieces[1], pos: Point2d(x: x1, y: y1)),
                                                    PieceWithPosition(piece: pieces[2], pos: Point2d(x: x2, y: y2))
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
        var result = "\n"
        for line in board {
            for b in line {
                result += b ? "x" : "+"
            }
            result += "\n"
        }
        return result
    }
}
