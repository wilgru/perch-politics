//
//  CatConfig.swift
//  Perch Politics
//
//  Created by William Gruszka on 1/2/2026.
//  Copyright © 2026 Matusalem Marques. All rights reserved.
//

import AppKit
import SpriteKit
import GameplayKit

final class CatInstance {
    let cat: Cat
//    let window: NSWindow
//    let sceneView: SKView
//    let scene: SKScene
//    let sprite: SKSpriteNode
    let stateMachine: GKStateMachine
    let timer: Timer

    init(cat: Cat,
//         window: NSWindow,
//         sceneView: SKView,
//         scene: SKScene,
//         sprite: SKSpriteNode,
         stateMachine: GKStateMachine,
         timer: Timer) {
        self.cat = cat
//        self.window = window
//        self.sceneView = sceneView
//        self.scene = scene
//        self.sprite = sprite
        self.stateMachine = stateMachine
        self.timer = timer
    }

    deinit {
        timer.invalidate()
    }
}
