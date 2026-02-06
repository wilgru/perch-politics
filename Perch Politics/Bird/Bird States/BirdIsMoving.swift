//
//  BirdIsMoving.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsMoving : BaseBirdState {
    var speed : CGFloat = 16.0
    
    var frames : [BirdDirection:[String]] = [
        .left : ["left1","left2"],
        .right : ["right1","right2"],
    ]
    
    var direction : BirdDirection = .left {
        didSet {
            guard direction != oldValue else { return }
            
            bird.sprite.removeAllActions()
            bird.sprite.run(movingAction)
        }
    }
    
    var movingAction : SKAction {
        let animationFrames = self.frames[direction]!
        return SKAction.repeatForever(SKAction.animate(with: animationFrames.map { bird.textures.textureNamed($0) }, timePerFrame: self.timePerFrame))
    }
    
    override init(flock: Flock, bird: Bird) {
        super.init(flock: flock, bird: bird)
        validNextStates = [ BirdIsStopped.self ]
    }
    
    override func didEnter(from previousState: GKState?) {
        time = 0.0
        
        let delta = NSPoint(x: bird.actualDesitnation.x - bird.position.x, y: bird.actualDesitnation.y - bird.position.y)
        direction = BirdDirection(vector: delta)
        
        bird.sprite.removeAllActions()
        bird.sprite.run(movingAction)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateMachine = stateMachine else { return }
        time += seconds
        
        if bird.distance <= CGFloat(2.squareRoot()) { // Maximum error in distance is sqrt(2)
            stateMachine.enter(BirdIsStopped.self)
            bird.settledOrder = flock.settledBirdsCount
            
            return
        }
        
        let delta = NSPoint(x: bird.actualDesitnation.x - bird.position.x, y: bird.actualDesitnation.y - bird.position.y)
        direction = BirdDirection(vector: delta)
        
        if bird.distance <= 20 { // TODO: use const for this value?
            bird.position = bird.actualDesitnation
//            velocity = .zero // keeping the last set velocity make for interesting movement next time they move
        } else {
            let cohesion = flock.cohesionVelocity(for: bird)
            let separation = flock.separationVelocity(for: bird)
            
            bird.velocity = NSPoint(
                x: (bird.velocity.x * 0.80) + cohesion.x + separation.x + (speed * delta.x / bird.distance),
                y: (bird.velocity.y * 0.80) + cohesion.y + separation.y + (speed * delta.y / bird.distance)
            )
            
            bird.position = NSPoint(x: bird.position.x + bird.velocity.x, y: bird.position.y + bird.velocity.y)
        }
    }
}
