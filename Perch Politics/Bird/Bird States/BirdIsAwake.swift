//
//  BirdIsAwake.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsAwake : BaseBirdState {
    var timeBeforeMoving : TimeInterval = 0.250
    var distanceBeforeMoving : CGFloat = 32.0
    
    override init(flock: Flock, bird: Bird) {
        super.init(flock: flock, bird: bird)
        validNextStates = [ BirdIsMoving.self, BirdIsStopped.self ]
        action = SKAction.setTexture(bird.textures.textureNamed("awake"))
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateMachine = stateMachine else { return }
        time += seconds
        
        if bird.distance >= distanceBeforeMoving && time >= timeBeforeMoving {
            stateMachine.enter(BirdIsMoving.self)
        } else if time >= timeBeforeNextState {
            stateMachine.enter(BirdIsStopped.self)
        }
    }
}
