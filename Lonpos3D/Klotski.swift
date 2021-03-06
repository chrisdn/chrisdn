//
//  Klotski.swift
//  Klotski
//
//  Created by Wei Dong on 2021-09-04.
//

import Foundation
import AppKit

struct Klotski {
    struct Step: CustomStringConvertible {
        var index: Int
        var char: Character
        var direction: Direction
        
        var description: String {
            return "\(char)@\(index % 4),\(index / 4)\(direction)"
        }
        
        enum Direction: CustomStringConvertible {
            case left, right, up, down
            
            var description: String {
                switch self {
                case .right:
                    return "=>"
                case .left:
                    return "<="
                case .down:
                    return "v"
                case .up:
                    return "^"
                }
            }
        }
    }
    var board: [Character]
    var steps = [Step]()
    
    init(_ string: String) {
        board = []
        for i in 0..<string.count {
            let start = string.startIndex
            let index = string.index(start, offsetBy: i)
            let char = string[index]
            board.append(contentsOf: String(char))
        }
        checkError()
    }
    
    func rowCol(index: Int) -> Point2d {
        return Point2d(x: index % 4, y: index / 4)
    }
    
    private var emptyPositions: [Point2d] {
        var result = [Point2d] ()
        for i in 0..<board.count where board[i] == " " {
            result.append(rowCol(index: i))
        }
        return result
    }
    
    private func processDown(index: Int, result: inout [Self]) {
        var copy = self
        if index > 3 && board[index - 4] != " " {
            switch board[index - 4] {
            case "v":
                copy.board[index] = board[index - 4]
                copy.board[index - 4] = board[index - 8]
                copy.board[index - 8] = " "
                copy.steps.append(Step(index: index - 8, char:"V", direction: .down))
                result.append(copy)
                copy = self
            case "H":
                if board[index + 1] == " " {
                    copy.board[index] = board[index - 4]
                    copy.board[index + 1] = board[index - 3]
                    copy.board[index - 4] = " "
                    copy.board[index - 3] = " "
                    copy.steps.append(Step(index: index - 4, char:"H", direction: .down))
                    result.append(copy)
                    copy = self
                }
            case "P":
                copy.board[index] = board[index - 4]
                copy.board[index - 4] = " "
                copy.steps.append(Step(index: index - 4, char:"P", direction: .down))
                result.append(copy)
                copy = self
            case "Q":
                if board[index + 1] == " "{
                    copy.board[index] = board[index - 4]
                    copy.board[index + 1] = board[index - 3]
                    copy.board[index - 4] = board[index - 8]
                    copy.board[index - 3] = board[index - 7]
                    copy.board[index - 8] = " "
                    copy.board[index - 7] = " "
                    copy.steps.append(Step(index: index - 8, char:"S", direction: .down))
                    result.append(copy)
                    copy = self
                    
                }
            case "h", "q":
                break
            default:
                abort()
            }
        }
    }
    
    private func processUp(index: Int, result: inout [Self]) {
        var copy = self
        if index < 16 && board[index + 4] != " " {
            switch board[index + 4] {
            case "H":
                if board[index + 1] == " " {
                    copy.board[index] = board[index + 4]
                    copy.board[index + 1] = board[index + 5]
                    copy.board[index + 4] = " "
                    copy.board[index + 5] = " "
                    copy.steps.append(Step(index: index + 4, char:"H", direction: .up))
                    result.append(copy)
                    copy = self
                }
            case "V":
                copy.board[index] = board[index + 4]
                copy.board[index + 4] = board[index + 8]
                copy.board[index + 8] = " "
                copy.steps.append(Step(index: index + 4, char:"V", direction: .up))
                result.append(copy)
                copy = self
            case "P":
                copy.board[index] = board[index + 4]
                copy.board[index + 4] = " "
                copy.steps.append(Step(index: index + 4, char:"P", direction: .up))
                result.append(copy)
                copy = self
            case "S":
                if board[index + 1] == " " {
                    copy.board[index] = board[index + 4]
                    copy.board[index + 1] = board[index + 5]
                    copy.board[index + 4] = board[index + 8]
                    copy.board[index + 5] = board[index + 9]
                    copy.board[index + 8] = " "
                    copy.board[index + 9] = " "
                    copy.steps.append(Step(index: index + 4, char:"S", direction: .up))
                    result.append(copy)
                    copy = self
                }
            case "h", "s":
                break
            default:
                abort()
            }
        }
    }
    
    private func processLeft(index: Int, result: inout [Self]) {
        var copy = self
        if index % 4 < 3 && board[index + 1] != " " {
            switch board[index + 1] {
            case "H":
                copy.board[index] = board[index + 1]
                copy.board[index + 1] = board[index + 2]
                copy.board[index + 2] = " "
                copy.steps.append(Step(index: index + 1, char:"H", direction: .left))
                result.append(copy)
                copy = self
            case "V":
                if board[index + 4] == " " {
                    copy.board[index] = board[index + 1]
                    copy.board[index + 4] = board[index + 5]
                    copy.board[index + 1] = " "
                    copy.board[index + 5] = " "
                    copy.steps.append(Step(index: index + 1, char:"V", direction: .left))
                    result.append(copy)
                    copy = self
                }
            case "P":
                copy.board[index] = board[index + 1]
                copy.board[index + 1] = " "
                copy.steps.append(Step(index: index + 1, char:"P", direction: .left))
                result.append(copy)
                copy = self
            case "S":
                if board[index + 4] == " " {
                    copy.board[index] = board[index + 1]
                    copy.board[index + 1] = board[index + 2]
                    copy.board[index + 4] = board[index + 5]
                    copy.board[index + 5] = board[index + 6]
                    copy.board[index + 2] = " "
                    copy.board[index + 6] = " "
                    copy.steps.append(Step(index: index + 1, char:"S", direction: .left))
                    result.append(copy)
                    copy = self
                }
            case "v", "Q":
                break
            default:
                abort()
            }
        }
    }
    
    private func processRight(index: Int, result: inout [Self]) {
        var copy = self
        if index % 4 > 0 && board[index - 1] != " " {
            switch board[index - 1] {
            case "h":
                copy.board[index] = board[index - 1]
                copy.board[index - 1] = board[index - 2]
                copy.board[index - 2] = " "
                copy.steps.append(Step(index: index - 2, char:"H", direction: .right))
                result.append(copy)
                copy = self
            case "V":
                if board[index + 4] == " " {
                    copy.board[index] = board[index - 1]
                    copy.board[index + 4] = board[index + 3]
                    copy.board[index - 1] = " "
                    copy.board[index + 3] = " "
                    copy.steps.append(Step(index: index - 1, char:"V", direction: .right))
                    result.append(copy)
                    copy = self
                }
            case "P":
                copy.board[index] = board[index - 1]
                copy.board[index - 1] = " "
                copy.steps.append(Step(index: index - 1, char:"P", direction: .right))
                result.append(copy)
                copy = self
            case "s":
                if board[index + 4] == " " {
                    copy.board[index] = board[index - 1]
                    copy.board[index - 1] = board[index - 2]
                    copy.board[index + 4] = board[index + 3]
                    copy.board[index + 3] = board[index + 2]
                    copy.board[index - 2] = " "
                    copy.board[index + 2] = " "
                    copy.steps.append(Step(index: index - 2, char:"S", direction: .right))
                    result.append(copy)
                    copy = self
                }
            case "v", "q":
                break
            default:
                abort()
            }
        }
    }
    
    var isSuccess: Bool {
        board[13] == "S"
    }
    
    func spawn() -> [Klotski] {
        var result = [Klotski]()
        for pos in emptyPositions {
            let index = pos.y * 4 + pos.x
           
            processDown(index: index, result: &result)
            processUp(index: index, result: &result)
            processLeft(index: index, result: &result)
            processRight(index: index, result: &result)
            
        }
        return result
    }
    
    func start() {
        var level = 0
        var hashSet = Set<Int>()
        hashSet.insert(board.hashValue)
        var list = [self]
        var nextList = [Self]()
        repeat {
            level += 1
            for game in list {
                if game.isSuccess {
                    print("success")
                    print(game)
                    NotificationQueue.default.enqueue(Notification(name: Game.notificationName, object: game, userInfo: nil), postingStyle: .now)
                    return
                }
                let spawnList = game.spawn()
                for g in spawnList {
                    let hash = g.board.hashValue
                    if !hashSet.contains(hash) {
                        hashSet.insert(hash)
                        nextList.append(g)
                    }
                }
            }
            list = nextList
            print(level, list.count, hashSet.count)
            if let g = list.randomElement() {
                g.checkError()
            }
        } while !list.isEmpty
    }
    
    func checkError() {
        if board.count != 20 {
            abort()
        }
        for i in 0..<board.count where board[i] != " " {
            switch board[i] {
            case "H":
                if i % 4 == 3 || board[i + 1] != "h" {
                    print(self)
                    print("H should have h at its right")
                    abort()
                }
            case "V":
                if i >= 16 || board[i + 4] != "v" {
                    print(self)
                    print("H should have v at its bottom")
                    abort()
                }
            case "S":
                if i > 20 || i % 4 == 3 || board[i + 1] != "s" || board[i + 4] != "Q" || board[i + 5] != "q" {
                    print(self)
                    print("SsQq should form a sqaure")
                    abort()
                }
            case "h", "v", "s", "Q", "q", "P":
                break
            default:
                print(self)
                print("Unknown piece in board:", board[i])
                abort()
            }
        }
    }
}

extension Klotski: CustomStringConvertible {
    var description: String {
        var result = "----\n"
        for i in 0..<board.count {
            result += String(board[i])
            if i % 4 == 3 {
                result += "\n"
            }
        }
        result += "\n----\n"
        for step in steps {
            result += "\(step) | "
        }
        result += "\n===="
        return result
    }
}
