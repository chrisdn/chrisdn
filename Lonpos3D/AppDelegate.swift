//
//  AppDelegate.swift
//  Lonpos3D
//
//  Created by Wei Dong on 2021-08-22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DispatchQueue.global(qos: .background).async {
            var game = Game()
            var usePieces = Set<Character>()
            let str = "UU  SU   SU  SSU  S" // initial board
            for i in 0..<str.count {
                let char = str[str.index(str.startIndex, offsetBy: i)]
                game.space[i] = char
                usePieces.insert(char)
            }
            usePieces.remove(" ")
            for i in 0..<game.pieceCandidates.count {
                let id = game.pieceCandidates[i].identifier
                if usePieces.contains(id) {
                    game.usePieceIndexes.insert(i)
                }
            }
            game.checkError()
            
            game.fillNextSpace()
            print("weiwei done")
        }
    }
}

struct Point2D {
    var x, y: Int
}

struct PointFloat3D {
    var x, y, z: Float
    
    func distance(from p: PointFloat3D) -> Int {
        let dx = x - p.x
        let dy = y - p.y
        let dz = z - p.z
        return Int(0.5 + dx * dx + dy * dy + dz * dz)
    }
}

struct PointInt3D {
    var x, y, z: Int
    static let sqrt2_2 = sqrtf(2) / 2
    
    func index(outOfBoundAllowed: Bool = false) -> Int {
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
    
    var seaPoint: Point2D {
        return Point2D(x: x + x + z, y: y + y + z)
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
    
    var floatPoint: PointFloat3D {
        return PointFloat3D(x: Float(x) + Float(z) / 2, y: Float(y) + Float(z) / 2, z: PointInt3D.sqrt2_2 * Float(z))
    }
}

extension PointInt3D: CustomDebugStringConvertible {
    var debugDescription: String {
        "(\(x),\(y),\(z))"
    }
}

extension PointInt3D: Equatable {
    public static func != (lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

struct Piece {
    var identifier: Character
    var ballCount: Int
    var maxLength: Int
    var distanceSet: Set<[Int]>
    
    func isValidPoints(pointList: [PointInt3D]) -> Bool {
        var tSet = Set<[Int]>()
        for i in 0..<pointList.count {
            let p0 = pointList[i].floatPoint
            var list = [Int]()
            for j in 0..<pointList.count where i != j {
                list.append(p0.distance(from: pointList[j].floatPoint))
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
        return Piece(identifier: "H", ballCount: 3, maxLength: 2, distanceSet: [[1,2], [1,1]])
    }
    
    static var L: Piece {
        return Piece(identifier: "L", ballCount: 4, maxLength: 5, distanceSet: [[1,4,5], [1,1,2], [1,1,4], [1,2,5]])
    }
    
    static var U: Piece {
        return Piece(identifier: "U", ballCount: 5, maxLength: 10, distanceSet: [[1,4,9,10], [1,1,4,5], [1,1,2,4], [1,1,4,9], [1,2,5,10]])
    }
    
    static var F: Piece {
        return Piece(identifier: "F", ballCount: 5, maxLength: 8, distanceSet: [[1,4,5,8], [1,1,2,5], [1,1,4,4]])
    }
    
    static var S: Piece {
        return Piece(identifier: "S", ballCount: 5, maxLength: 10, distanceSet: [[1,4,5,10], [1,1,2,5], [1,1,2,4], [1,1,2,5], [1,2,5,10]])
    }
    
    static var C: Piece {
        return Piece(identifier: "C", ballCount: 5, maxLength: 5, distanceSet: [[1,2,4,5], [1,1,4,5], [1,1,2,2]])
    }
    
    static var W: Piece {
        return Piece(identifier: "W", ballCount: 5, maxLength: 8, distanceSet: [[1,2,5,8], [1,1,2,5], [1,1,2,2]])
    }
    
    static var X: Piece {
        return Piece(identifier: "X", ballCount: 5, maxLength: 4, distanceSet: [[1,1,1,1], [1,2,2,4]])
    }
    
    static var B: Piece {
        return Piece(identifier: "B", ballCount: 5, maxLength: 5, distanceSet: [[1,2,4,5], [1,1,1,2], [1,1,2,2], [1,1,2,4], [1,1,2,5]])
    }
    
    static var Z: Piece {
        return Piece(identifier: "Z", ballCount: 4, maxLength: 2, distanceSet: [[1,1,2]])
    }
    
    static var O: Piece {
        return Piece(identifier: "O", ballCount: 4, maxLength: 9, distanceSet: [[1,4,9], [1,1,4]])
    }
    
    static var Y: Piece {
        return Piece(identifier: "Y", ballCount: 5, maxLength: 9, distanceSet: [[1,2,4,9], [1,1,1,4], [1,2,2,5], [1,1,2,4], [1,4,5,9]])
    }
}

struct Game {
    var space = Array(repeating: Character(" "), count: 55)
    let pieceCandidates: [Piece] = [Piece.H, Piece.L, Piece.U, Piece.F, Piece.S, Piece.C, Piece.W, Piece.X, Piece.B, Piece.Z, Piece.O, Piece.Y]
    var usePieceIndexes = IndexSet()
    
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
            //4 heighbors in upper level
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
    
    private func nextEmptyPosition(from lastPoint: PointInt3D? = nil) -> PointInt3D? {
        if let lp = lastPoint, lp.index() >= 54 {return nil}
        
        for i in ((lastPoint?.index() ?? 0) + 1)...54 where space[i] == " " {
            return PointInt3D.point(from: i);
        }
        return nil
    }
    
    private func isSameZ(pointList: [PointInt3D]) -> Bool {
        var set = Set<Int>()
        for p in pointList {
            set.insert(p.z)
            if set.count > 1 {
                return false
            }
        }
        return true
    }
    
    private func isSamePlaneVertically(pointList: [PointInt3D]) -> Bool {
        var plusSet = Set<Int>()
        var minusSet = Set<Int>()
        for p in pointList {
            let seaPoint = p.seaPoint
            plusSet.insert(seaPoint.x + seaPoint.y)
            minusSet.insert(seaPoint.x - seaPoint.y)
            if plusSet.count > 1 && minusSet.count > 1 {
                return false
            }
        }
        return true
    }
    
    mutating func fillNextSpace() {
        func getNextPointList(points: inout [PointInt3D], piece: Piece) -> Bool {
            var lp = points.removeLast()
            space[lp.index()] = " "
            repeat {
                guard let np = nextEmptyPosition(from: lp) else {
                    if points.count < 2 {
                        return false
                    }
                    lp = points.removeLast()
                    space[lp.index()] = " "
                    continue
                }
                lp = np
                //make sure piece.maxLength is cmplied
                let p0 = np.floatPoint
                if points.count > 1 {
                    for i in 0..<points.count - 1 {
                        let distance = p0.distance(from: points[i].floatPoint)
                        if distance > piece.maxLength {
                            continue
                        }
                    }
                }
                
                points.append(np)
                space[np.index()] = piece.identifier
            } while points.count < piece.ballCount
            
            return true
        }
        
        guard let firstPos = nextEmptyPosition() else {return}
        for i in 0..<pieceCandidates.count where !usePieceIndexes.contains(i) {
            let piece = pieceCandidates[i]
            space[firstPos.index()] = piece.identifier
            var pointList = [firstPos]
            while (true) {
                
                while pointList.count < piece.ballCount {
                    guard let p = nextEmptyPosition(from: pointList.last) else {break}
                    pointList.append(p)
                    space[p.index()] = piece.identifier
                }
                if pointList.count < piece.ballCount {
                    if getNextPointList(points: &pointList, piece: piece) {continue}
                    break
                }
                
//                if piece.identifier == "C" {
//                    var debugstr = ""
//                    for p in pointList {
//                        debugstr += "\(p.x)\(p.y)\(p.z)"
//                    }
//                    if debugstr.hasPrefix("111002112113004") {
//                        printMe()
//                    }
//                }
                
                //check if all points belong to a same plane
                if !isSameZ(pointList: pointList) && !isSamePlaneVertically(pointList: pointList) {
                    if getNextPointList(points: &pointList, piece: piece) {continue}
                    break
                }
                
                //check if any 2 points distance match piece distance set
                if !piece.isValidPoints(pointList: pointList) {
                    if getNextPointList(points: &pointList, piece: piece) {continue}
                    break
                }
                
                usePieceIndexes.insert(i)
                printMe()
//                checkError()
                
                //check if complete
                if nextEmptyPosition() == nil {
                    print("weiwei success")
                    print(space)
                    abort()
                }
                
                fillNextSpace()
                
                //continue from last step as if no match has been found
                usePieceIndexes.remove(i)
                
                if getNextPointList(points: &pointList, piece: piece) {continue}
                break
            }
            
            space[pointList[0].index()] = " "
        }
    }
    
    private func printMe() {
        var stringList = Array(repeating: "", count: 5)
        for z in 0...4 {
            for y in 0...4 - z {
                if stringList[y].isEmpty {stringList[y] = "\(y)) "}
                for x in 0...4 - z {
                    stringList[y] += String(space[PointInt3D(x: x, y: y, z: z).index()])
                }
                stringList[y] += "  "
            }
        }
        let numberSum = stringList.reduce("", { x, y in
            x + y + "\n"
        })
        print(numberSum)
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
        for i in 0..<pieceCandidates.count {
            let piece = pieceCandidates[i]
            if usePieceIndexes.contains(i) {
                assert(map[piece.identifier] == piece.ballCount, "piece \(piece.identifier) ball count is \(map[piece.identifier] ?? 0), but should be \(piece.ballCount)")
            } else {
                assert((map[piece.identifier] ?? 0) == 0)
            }
        }
    }
}