//
//  BaseBirdState.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/17.
//

import SpriteKit
import GameplayKit

class BaseBirdState : GKState {
    unowned let flock: Flock  // unowned to avoid retain cycles
    unowned let bird: Bird
    
    var time: TimeInterval = 0.0
    var timePerFrame: TimeInterval = 0.125
    var timeBeforeNextState: TimeInterval = 2.0
    var distanceBeforeWakingUp: CGFloat = 32.0

    var validNextStates = [AnyClass]()
    var nextState: AnyClass?
    
    var action : SKAction! = nil
    
    init(flock: Flock, bird: Bird) {
        self.flock = flock
        self.bird = bird
    }
    
    override func didEnter(from previousState: GKState?) {
        time = 0.0
        bird.sprite.removeAllActions()
        bird.sprite.run(action)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateMachine = stateMachine else { return }
        time += seconds
        
        if bird.distance < distanceBeforeWakingUp {
            bird.position = bird.actualDesitnation
        } else if bird.distance > distanceBeforeWakingUp {
            stateMachine.enter(BirdIsAwake.self)
        } else if let nextState = nextState, time >= timeBeforeNextState {
            stateMachine.enter(nextState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return validNextStates.contains { $0 == stateClass }
    }
}
