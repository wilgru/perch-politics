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

    override init(sprite: SKSpriteNode, playfield: CatPlayfield, textures: SKTextureAtlas) {
        super.init(sprite: sprite, playfield: playfield, textures: textures)
        timeBeforeNextState = 5.0
        validNextStates = [ CatIsAwake.self, CatIsScratching.self ]
        nextState = CatIsScratching.self
    }
    
    override func didEnter(from previousState: GKState?) {
        time = 0.0
        let origin = playfield.catPosition
        let destination = playfield.destination
        let delta = NSPoint(x: destination.x - origin.x, y: destination.y - origin.y)
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
