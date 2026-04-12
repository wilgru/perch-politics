//
//  BirdIsBlinking.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsBlinking: BaseBirdState {
    var frame: [BirdDirection:String] = [
        .left: "blink_left",
        .right: "blink_right"
    ]

    private var blinkingAction: SKAction {
        SKAction.repeatForever(
            SKAction.animate(
                with: [frame[bird.direction]!].map { bird.textures.textureNamed($0) },
                timePerFrame: self.timePerFrame
            )
        )
    }
    
    override init(flock: Flock, bird: Bird) {
        super.init(flock: flock, bird: bird)
        timeBeforeNextState = 0.20
        validNextStates = [ BirdIsIdle.self, BirdIsStretching.self ]
        nextState = BirdIsIdle.self
    }

    override func didEnter(from previousState: GKState?) {
        nextState = Int.random(in: 1...4) == 4 ? BirdIsStretching.self : BirdIsIdle.self
        action = blinkingAction
        super.didEnter(from: previousState)
    }
}
