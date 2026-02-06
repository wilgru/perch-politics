//
//  BirdIsStopped.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsStopped : BaseBirdState {
    override init(flock: Flock, bird: Bird) {
        super.init(flock: flock, bird: bird)
        validNextStates = [ BirdIsAwake.self, BirdIsLicking.self ]
        nextState = BirdIsLicking.self
        action = SKAction.setTexture(bird.textures.textureNamed("mati2"))
    }
}
