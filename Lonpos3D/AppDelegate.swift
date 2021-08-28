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
//            Game.start("BBFFFBBWSFBWWSFWWYSSYYYYS")
            Game.start("UU  SU   SU  SSU  S")
        }
    }
}
