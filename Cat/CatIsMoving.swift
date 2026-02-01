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
    
    override init(sprite: SKSpriteNode, playfield: CatPlayfield, textures: SKTextureAtlas) {
        super.init(sprite: sprite, playfield: playfield, textures: textures)
        validNextStates = [ CatIsStopped.self ]
    }
    
    override func didEnter(from previousState: GKState?) {
        time = 0.0
        let origin = playfield.catPosition
        let destination = playfield.destination
        let delta = NSPoint(x: destination.x - origin.x, y: destination.y - origin.y)
        direction = CatDirection(vector: delta)
        sprite.removeAllActions()
        sprite.run(movingAction)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateMachine = stateMachine else { return }
        time += seconds
        
        let origin = playfield.catPosition
        let destination = playfield.destination
        let delta = NSPoint(x: destination.x - origin.x, y: destination.y - origin.y)
        let distance = hypot(delta.x, delta.y)
        
        if distance <= CGFloat(2.squareRoot()) { // Maximum error in distance is sqrt(2)
            stateMachine.enter(CatIsStopped.self)
            return
        }
        
        direction = CatDirection(vector: delta)
        
        if distance <= speed {
            playfield.catPosition = destination
        } else {
            let newPosition = NSPoint(x: origin.x + speed * delta.x / distance, y: origin.y + speed * delta.y / distance)
            playfield.catPosition = newPosition
        }
    }
}
