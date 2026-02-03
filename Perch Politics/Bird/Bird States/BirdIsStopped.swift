//
//  BirdIsStopped.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsStopped : BirdState {
    override init(birdIdentity: BirdIdentity, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        validNextStates = [ BirdIsAwake.self, BirdIsLicking.self ]
        nextState = BirdIsLicking.self
        action = SKAction.setTexture(self.textures.textureNamed("mati2"))
    }
}
