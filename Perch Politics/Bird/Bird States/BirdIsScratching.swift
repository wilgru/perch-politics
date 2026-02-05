//
//  BirdIsScratching.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsScratching : BaseBirdState { // kaki
    override init(flockContext: FlockContext, bird: Bird) {
        super.init(flockContext: flockContext, bird: bird)
        validNextStates = [ BirdIsAwake.self, BirdIsYawning.self ]
        nextState = BirdIsYawning.self
        action = SKAction.repeatForever(SKAction.animate(with: ["kaki1", "kaki2"].map { bird.textures.textureNamed($0) }, timePerFrame: self.timePerFrame))
    }
}
