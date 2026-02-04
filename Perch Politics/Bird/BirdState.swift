//
//  BirdState.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/17.
//

import SpriteKit
import GameplayKit

class BirdState : GKState {
    unowned let flockContext: FlockContext  // unowned to avoid retain cycles

    var birdIdentity: BirdIdentity
    var sprite: SKSpriteNode
    var textures: SKTextureAtlas
    weak var window: NSWindow? // TODO: better practice would be not to strongly reference the window in here. Use a weak var, or require the window when calling stateMachine.update() in the timer
    var velocity: NSPoint = NSPoint(x: 1, y: 1)
    var position: NSPoint {
        get {
            guard let window else { return .zero }
            return window.frame.origin
        }
        set {
            guard let window else { return }
            window.setFrameOrigin(newValue)
        }
//        didSet {
//            window?.setFrameOrigin(position)
//        }
    }
    var actualDesitnation: NSPoint {
        get {
            let order = flockContext.birdSettledOrder[birdIdentity] ?? flockContext.birdSettledOrder.count
            return NSPoint(x: flockContext.destination.x + CGFloat(order * 64), y: flockContext.destination.y) // TODO: use const for 64?
        }
    }
    var distance: CGFloat {
        get {
            return hypot(actualDesitnation.x - position.x, actualDesitnation.y - position.y)
        }
    }
    
    var time: TimeInterval = 0.0
    var timePerFrame: TimeInterval = 0.125
    var timeBeforeNextState: TimeInterval = 2.0
    var distanceBeforeWakingUp: CGFloat = 32.0

    var validNextStates = [AnyClass]()
    var nextState: AnyClass?
    
    var action : SKAction! = nil
    
    init(birdIdentity: BirdIdentity, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        self.birdIdentity = birdIdentity
        self.sprite = sprite
        self.textures = textures
        self.window = window
//        self.position = window.frame.origin
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
            stateMachine.enter(BirdIsAwake.self)
        } else if let nextState = nextState, time >= timeBeforeNextState {
            stateMachine.enter(nextState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return validNextStates.contains { $0 == stateClass }
    }
}



