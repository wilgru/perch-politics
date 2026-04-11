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
    override init(flock: Flock, bird: Bird) {
        super.init(flock: flock, bird: bird)
        validNextStates = [ BirdIsAwake.self, BirdIsIdle.self ]
        nextState = BirdIsIdle.self
        action = SKAction.repeatForever(SKAction.animate(with: ["stretch_left_1", "stretch_left_2", "stretch_left_3", "stretch_left_4", "stretch_left_3", "stretch_left_2", "stretch_left_1"].map { bird.textures.textureNamed($0) }, timePerFrame: self.timePerFrame))
    }
}
