//
//  BirdIsYawning.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsYawning : BirdState { // akubi
    override init(birdIdentity: BirdIdentity, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        validNextStates = [ BirdIsAwake.self, BirdIsScratching.self, BirdIsSleeping.self ]
        nextState = BirdIsSleeping.self
        action = SKAction.setTexture(self.textures.textureNamed("mati3"))
    }
}
