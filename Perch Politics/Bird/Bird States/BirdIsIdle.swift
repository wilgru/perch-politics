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
        validNextStates = [ BirdIsFlying.self, BirdIsBlinking.self, BirdIsStretching.self ]
        nextState = BirdIsBlinking.self
    }

    override func didEnter(from previousState: GKState?) {
        action = idleAction
        super.didEnter(from: previousState)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateMachine = stateMachine else { return }
        time += seconds
        
        if bird.distance < distanceBeforeFlying {
            bird.position = bird.actualDesitnation
        } else if bird.distance > distanceBeforeFlying {
            stateMachine.enter(BirdIsFlying.self)
            return
        }
        
        let randomInt = Int.random(in: 0...500)
        if (randomInt == 200 || randomInt == 300) {
            stateMachine.enter(BirdIsBlinking.self)
            return
        } else if randomInt == 400 {
            bird.direction = bird.direction == .left ? .right : .left
            bird.sprite.removeAllActions()
            bird.sprite.run(idleAction)
            return
        } else if randomInt == 500 {
            stateMachine.enter(BirdIsStretching.self)
            return
        }
    }
}
