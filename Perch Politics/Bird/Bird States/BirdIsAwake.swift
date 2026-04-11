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

    private var awakeAction: SKAction {
        let textureName = bird.direction == .left ? "idle_left" : "idle_right"
        return SKAction.setTexture(bird.textures.textureNamed(textureName))
    }
    
    override init(flock: Flock, bird: Bird) {
        super.init(flock: flock, bird: bird)
        validNextStates = [ BirdIsFlying.self, BirdIsIdle.self ]
    }

    override func didEnter(from previousState: GKState?) {
        action = awakeAction
        super.didEnter(from: previousState)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateMachine = stateMachine else { return }
        time += seconds
        
        if bird.distance >= distanceBeforeMoving && time >= timeBeforeMoving {
            stateMachine.enter(BirdIsFlying.self)
        } else if time >= timeBeforeNextState {
            stateMachine.enter(BirdIsIdle.self)
        }
    }
}
