//
//  CatState.swift
//  Cat
//
//  Created by Matusalem Marques on 2017/02/17.
//

import SpriteKit
import GameplayKit

class CatState : GKState {
    unowned let flockContext: FlockContext  // unowned to avoid retain cycles

    var catIdentity: Cat
    var sprite : SKSpriteNode
    var textures: SKTextureAtlas
    var window: NSWindow
    var position: NSPoint {
        get {
            return window.frame.origin
        }
        set {
            window.setFrameOrigin(newValue)
        }
    }
    var actualDesitnation: NSPoint {
        get {
            let order = flockContext.birdSettledOrder[catIdentity] ?? flockContext.birdSettledOrder.count
            return NSPoint(x: flockContext.destination.x + CGFloat(order * 64), y: flockContext.destination.y)
        }
    }
    var distance: CGFloat {
        get {
            return hypot(actualDesitnation.x - position.x, actualDesitnation.y - position.y)
        }
    }
    
    var time : TimeInterval = 0.0
    var timePerFrame : TimeInterval = 0.125
    var timeBeforeNextState : TimeInterval = 2.0
    var distanceBeforeWakingUp : CGFloat = 32.0

    var validNextStates = [AnyClass]()
    var nextState : AnyClass?
    
    var action : SKAction! = nil
    
    init(catIdentity: Cat, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        self.catIdentity = catIdentity
        self.sprite = sprite
        self.textures = textures
        self.window = window
        self.flockContext = flockContext
    }
    
    override func didEnter(from previousState: GKState?) {
        time = 0.0
        sprite.removeAllActions()
        sprite.run(action)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateMachine = stateMachine else { return }
        time += seconds
        
        if distance < distanceBeforeWakingUp {
            position = actualDesitnation
        } else if distance > distanceBeforeWakingUp {
            stateMachine.enter(CatIsAwake.self)
        } else if let nextState = nextState, time >= timeBeforeNextState {
            stateMachine.enter(nextState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return validNextStates.contains { $0 == stateClass }
    }
}



