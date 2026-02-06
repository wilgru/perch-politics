//
//  BirdIsLicking.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsLicking : BaseBirdState { // jare
    override init(flock: Flock, bird: Bird) {
        super.init(flock: flock, bird: bird)
        validNextStates = [ BirdIsAwake.self, BirdIsScratching.self ]
        nextState = BirdIsScratching.self
        action = SKAction.repeatForever(SKAction.animate(with: ["jare2", "mati2"].map { bird.textures.textureNamed($0) }, timePerFrame: self.timePerFrame))
    }
}
