//
//  BirdIsGoingToSleep.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsGoingToSleep : BaseBirdState { // akubi
    override init(flock: Flock, bird: Bird) {
        super.init(flock: flock, bird: bird)
        validNextStates = [ BirdIsAwake.self, BirdIsStretching.self, BirdIsSleeping.self ]
        nextState = BirdIsSleeping.self
        action = SKAction.setTexture(bird.textures.textureNamed("mati3"))
    }
}
