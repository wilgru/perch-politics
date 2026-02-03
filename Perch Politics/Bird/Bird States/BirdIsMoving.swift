//
//  BirdIsMoving.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsMoving : BirdState {
    var speed : CGFloat = 16.0
    
    var frames : [BirdDirection:[String]] = [
        .left : ["left1","left2"],
        .right : ["right1","right2"],
    ]
    
    var direction : BirdDirection = .left {
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
    
    override init(birdIdentity: BirdIdentity, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        validNextStates = [ BirdIsStopped.self ]
    }
    
    override func didEnter(from previousState: GKState?) {
        time = 0.0
        
        let delta = NSPoint(x: actualDesitnation.x - position.x, y: actualDesitnation.y - position.y)
        direction = BirdDirection(vector: delta)
        
        sprite.removeAllActions()
        sprite.run(movingAction)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateMachine = stateMachine else { return }
        time += seconds
        
        if distance <= CGFloat(2.squareRoot()) { // Maximum error in distance is sqrt(2)
            stateMachine.enter(BirdIsStopped.self)
            flockContext.birdSettledOrder[birdIdentity] = flockContext.birdSettledOrder.count
            
            return
        }
        
        let delta = NSPoint(x: actualDesitnation.x - position.x, y: actualDesitnation.y - position.y)
        direction = BirdDirection(vector: delta)
        
        if distance <= 20 { // TODO: use const for this value?
            position = actualDesitnation
//            velocity = .zero // keeping the last set velocity make for interesting movement next time they move
        } else {
            let cohesion = flockContext.cohesionVelocity(for: birdIdentity)
            let separation = flockContext.separationVelocity(for: birdIdentity)
            
            velocity = NSPoint(
                x: (velocity.x * 0.80) + cohesion.x + separation.x + (speed * delta.x / distance),
                y: (velocity.y * 0.80) + cohesion.y + separation.y + (speed * delta.y / distance)
            )
            
            position = NSPoint(x: position.x + velocity.x, y: position.y + velocity.y)
        }
        
        flockContext.birdPositions[birdIdentity] = position
    }
}
