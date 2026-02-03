//
//  BirdIsSleeping.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsSleeping : BirdState {
    override init(birdIdentity: BirdIdentity, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        timePerFrame = 0.5
        validNextStates = [ BirdIsAwake.self, BirdIsSleeping.self ]
        action = SKAction.repeatForever(SKAction.animate(with: ["sleep1", "sleep2"].map { self.textures.textureNamed($0) }, timePerFrame: self.timePerFrame))
    }
}
