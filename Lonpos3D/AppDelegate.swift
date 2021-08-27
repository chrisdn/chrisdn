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
        let queue = DispatchQueue(label: "lonpos_queue")
        queue.async {
            var game = Game()
            var usePieces = Set<Character>()
            // initial board
            let str =
            //"BBFFFBBWSFBWWSFWWYSSYYYYS"
            "UU  SU   SU  SSU  S"
            for i in 0..<str.count {
                let char = str[str.index(str.startIndex, offsetBy: i)]
                game.space[i] = char
                usePieces.insert(char)
            }
            usePieces.remove(" ")
            for i in 0..<Game.pieceCandidates.count {
                let id = Game.pieceCandidates[i].identifier
                if usePieces.contains(id) {
                    game.usePieceIndexes.insert(i)
                }
            }
            game.checkError()
            
            Game.start(game: game)
        }
    }
}
