//
//  CatIsClawing.swift
//  Cat
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class CatIsClawing : CatState { // togi
    var frames : [CatDirection:[String]] = [
        .left : ["ltogi","ltogi2"],
        .right : ["rtogi1","rtogi2"],
    ]
    
    var direction : CatDirection = .right {
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

    override init(catIdentity: CatIdentity, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(catIdentity: catIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        timeBeforeNextState = 5.0
        validNextStates = [ CatIsAwake.self, CatIsScratching.self ]
        nextState = CatIsScratching.self
    }
    
    override func didEnter(from previousState: GKState?) {
        time = 0.0

        let delta = NSPoint(x: flockContext.destination.x - position.x, y: flockContext.destination.y - position.y)
        direction = CatDirection.squared(vector: delta)
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
