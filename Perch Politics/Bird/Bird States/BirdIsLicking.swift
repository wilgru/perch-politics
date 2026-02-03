//
//  BirdIsLicking.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class BirdIsLicking : BirdState { // jare
    override init(birdIdentity: BirdIdentity, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        validNextStates = [ BirdIsAwake.self, BirdIsScratching.self ]
        nextState = BirdIsScratching.self
        action = SKAction.repeatForever(SKAction.animate(with: ["jare2", "mati2"].map { self.textures.textureNamed($0) }, timePerFrame: self.timePerFrame))
    }
}
