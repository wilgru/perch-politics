//
//  BirdIsSleeping.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsSleeping : BaseBirdState {
    override init(flockContext: FlockContext, bird: Bird) {
        super.init(flockContext: flockContext, bird: bird)
        timePerFrame = 0.5
        validNextStates = [ BirdIsAwake.self, BirdIsSleeping.self ]
        action = SKAction.repeatForever(SKAction.animate(with: ["sleep1", "sleep2"].map { bird.textures.textureNamed($0) }, timePerFrame: self.timePerFrame))
    }
}
