//
//  BirdIsIdle.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsIdle: BaseBirdState {
    var frame: [BirdDirection:String] = [
        .left: "idle_left",
        .right: "idle_right"
    ]

    private var idleAction: SKAction {
        SKAction.setTexture(bird.textures.textureNamed(frame[bird.direction]!))
    }
    
    override init(flock: Flock, bird: Bird) {
        super.init(flock: flock, bird: bird)
        validNextStates = [ BirdIsAwake.self, BirdIsBlinking.self ]
        nextState = BirdIsBlinking.self
    }

    override func didEnter(from previousState: GKState?) {
        action = idleAction
        super.didEnter(from: previousState)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateMachine = stateMachine else { return }
        time += seconds
        
        if bird.distance < distanceBeforeWakingUp {
            bird.position = bird.actualDesitnation
        } else if bird.distance > distanceBeforeWakingUp {
            stateMachine.enter(BirdIsAwake.self)
        }
        
        var randomInt = Int.random(in: 1...100)
        if randomInt > 99 {
            stateMachine.enter(BirdIsBlinking.self)
            return
        }
        
        randomInt = Int.random(in: 1...100)
        if randomInt > 99 {
            bird.direction = bird.direction == .left ? .right : .left
            bird.sprite.removeAllActions()
            bird.sprite.run(idleAction)
            return
        }
    }
}
