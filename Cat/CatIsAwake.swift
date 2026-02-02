//
//  CatIsAwake.swift
//  Cat
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class CatIsAwake : CatState {
    var timeBeforeMoving : TimeInterval = 0.250
    var distanceBeforeMoving : CGFloat = 32.0
    
    override init(catIdentity: Cat, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(catIdentity: catIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        validNextStates = [ CatIsMoving.self, CatIsStopped.self ]
        action = SKAction.setTexture(self.textures.textureNamed("awake"))
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateMachine = stateMachine else { return }
        time += seconds
        
        if distance >= distanceBeforeMoving && time >= timeBeforeMoving {
            stateMachine.enter(CatIsMoving.self)
        } else if time >= timeBeforeNextState {
            stateMachine.enter(CatIsStopped.self)
        }
    }
}
