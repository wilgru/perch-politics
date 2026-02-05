//
//  BirdIsYawning.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsYawning : BaseBirdState { // akubi
    override init(flockContext: FlockContext, bird: Bird) {
        super.init(flockContext: flockContext, bird: bird)
        validNextStates = [ BirdIsAwake.self, BirdIsScratching.self, BirdIsSleeping.self ]
        nextState = BirdIsSleeping.self
        action = SKAction.setTexture(bird.textures.textureNamed("mati3"))
    }
}
