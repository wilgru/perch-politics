//
//  CatIsSleeping.swift
//  Cat
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class CatIsSleeping : CatState {
    override init(catIdentity: CatIdentity, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(catIdentity: catIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        timePerFrame = 0.5
        validNextStates = [ CatIsAwake.self, CatIsSleeping.self ]
        action = SKAction.repeatForever(SKAction.animate(with: ["sleep1", "sleep2"].map { self.textures.textureNamed($0) }, timePerFrame: self.timePerFrame))
    }
}
