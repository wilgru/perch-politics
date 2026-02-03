//
//  BirdIsScratching.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsScratching : BirdState { // kaki
    override init(birdIdentity: BirdIdentity, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        validNextStates = [ BirdIsAwake.self, BirdIsYawning.self ]
        nextState = BirdIsYawning.self
        action = SKAction.repeatForever(SKAction.animate(with: ["kaki1", "kaki2"].map { self.textures.textureNamed($0) }, timePerFrame: self.timePerFrame))
    }
}
