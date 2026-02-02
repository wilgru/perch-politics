//
//  CatIsMoving.swift
//  Cat
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class CatIsMoving : CatState {
    var speed : CGFloat = 30.0
    
    var frames : [CatDirection:[String]] = [
        .left : ["left1","left2"],
        .right : ["right1","right2"],
    ]
    
    var direction : CatDirection = .left {
        didSet {
            guard direction != oldValue else { return }
            
            sprite.removeAllActions()
            sprite.run(movingAction)
        }
    }
    
    var movingAction : SKAction {
        let animationFrames = self.frames[direction]!
        return SKAction.repeatForever(SKAction.animate(with: animationFrames.map { self.textures.textureNamed($0) }, timePerFrame: self.timePerFrame))
    }
    
    override init(catIdentity: Cat, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(catIdentity: catIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        validNextStates = [ CatIsStopped.self ]
        
        print("actualDesitnation.x \(actualDesitnation.x)")
    }
    
    override func didEnter(from previousState: GKState?) {
        time = 0.0
        let delta = NSPoint(x: actualDesitnation.x - position.x, y: actualDesitnation.y - position.y)
        direction = CatDirection(vector: delta)
        sprite.removeAllActions()
        sprite.run(movingAction)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateMachine = stateMachine else { return }
        time += seconds
        
        let delta = NSPoint(x: actualDesitnation.x - position.x, y: actualDesitnation.y - position.y)
        
        if distance <= CGFloat(2.squareRoot()) { // Maximum error in distance is sqrt(2)
            stateMachine.enter(CatIsStopped.self)
            flockContext.birdSettledOrder[catIdentity] = flockContext.birdSettledOrder.count
            
            return
        }
        
        direction = CatDirection(vector: delta)
        
        if distance <= speed {
            position = actualDesitnation
        } else {
            let newPosition = NSPoint(x: position.x + speed * delta.x / distance, y: position.y + speed * delta.y / distance)
            position = newPosition
        }
        
        flockContext.birdPositions[catIdentity] = position
    }
}
