//
//  BirdIsAwake.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsAwake : BirdState {
    var timeBeforeMoving : TimeInterval = 0.250
    var distanceBeforeMoving : CGFloat = 32.0
    
    override init(birdIdentity: BirdIdentity, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        validNextStates = [ BirdIsMoving.self, BirdIsStopped.self ]
        action = SKAction.setTexture(self.textures.textureNamed("awake"))
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateMachine = stateMachine else { return }
        time += seconds
        
        if distance >= distanceBeforeMoving && time >= timeBeforeMoving {
            stateMachine.enter(BirdIsMoving.self)
        } else if time >= timeBeforeNextState {
            stateMachine.enter(BirdIsStopped.self)
        }
    }
}
