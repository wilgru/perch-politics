//
//  BirdIsClawing.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsClawing : BirdState { // togi
    var frames : [BirdDirection:[String]] = [
        .left : ["ltogi","ltogi2"],
        .right : ["rtogi1","rtogi2"],
    ]
    
    var direction : BirdDirection = .right {
        didSet {
            guard direction != oldValue else { return }
            
            sprite.removeAllActions()
            sprite.run(clawingAction)
        }
    }
    
    var clawingAction : SKAction {
        let animationFrames = self.frames[direction]!
        return SKAction.repeatForever(SKAction.animate(with: animationFrames.map { self.textures.textureNamed($0) }, timePerFrame: self.timePerFrame))
    }

    override init(birdIdentity: BirdIdentity, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        timeBeforeNextState = 5.0
        validNextStates = [ BirdIsAwake.self, BirdIsScratching.self ]
        nextState = BirdIsScratching.self
    }
    
    override func didEnter(from previousState: GKState?) {
        time = 0.0

        let delta = NSPoint(x: flockContext.destination.x - position.x, y: flockContext.destination.y - position.y)
        direction = BirdDirection.squared(vector: delta)
        sprite.removeAllActions()
        sprite.run(clawingAction)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateMachine = stateMachine else { return }
        time += seconds
  
        if let nextState = nextState, time >= timeBeforeNextState {
            stateMachine.enter(nextState.self)
        }
    }
}
