//
//  BirdIsStretching.swift
//  Perch Politics
//
//  Created by William Gruszka on 8/2/2026.
//  Copyright © 2026 Matusalem Marques. All rights reserved.
//

import SpriteKit
import GameplayKit

class BirdIsStretching: BaseBirdState {
    private var frames: [BirdDirection:[String]] = [
        .left: ["stretch_left_1", "stretch_left_2", "stretch_left_3", "stretch_left_4", "stretch_left_4", "stretch_left_4", "stretch_left_3", "stretch_left_2", "stretch_left_1"],
        .right: ["stretch_right_1", "stretch_right_2", "stretch_right_3", "stretch_right_4", "stretch_right_4", "stretch_right_4", "stretch_right_3", "stretch_right_2", "stretch_right_1"]
    ]

    override init(flock: Flock, bird: Bird) {
        super.init(flock: flock, bird: bird)
        timePerFrame = 0.18
        validNextStates = [ BirdIsAwake.self, BirdIsIdle.self ]
        nextState = BirdIsIdle.self
    }

    override func didEnter(from previousState: GKState?) {
        let animationFrames = frames[bird.direction]!
        timeBeforeNextState = Double(animationFrames.count) * timePerFrame
        action = SKAction.animate(with: animationFrames.map { bird.textures.textureNamed($0) }, timePerFrame: timePerFrame)

        super.didEnter(from: previousState)
    }
}
