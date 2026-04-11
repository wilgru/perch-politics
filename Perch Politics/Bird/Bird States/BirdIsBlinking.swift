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
    
    override init(flock: Flock, bird: Bird) {
        super.init(flock: flock, bird: bird)
        validNextStates = [ BirdIsIdle.self, BirdIsStretching.self ]
        nextState = BirdIsIdle.self
        action = SKAction.repeatForever(SKAction.animate(with: [frame[bird.direction]!].map { bird.textures.textureNamed($0) }, timePerFrame: self.timePerFrame))
    }
}
