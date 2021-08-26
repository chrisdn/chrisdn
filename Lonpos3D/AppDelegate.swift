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
            // initial board
            let str =
            "BBFFFBBWSFBWWSFWWYSSYYYYS"
             //"UU  SU   SU  SSU  S"
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
            
//            game.fillNextSpace(level: 0)
            Game.start(game: game)
            print("weiwei done")
        }
    }
}
