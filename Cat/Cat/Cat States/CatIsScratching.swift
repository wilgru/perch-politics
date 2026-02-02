//
//  CatIsScratching.swift
//  Cat
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class CatIsScratching : CatState { // kaki
    override init(catIdentity: CatIdentity, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(catIdentity: catIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        validNextStates = [ CatIsAwake.self, CatIsYawning.self ]
        nextState = CatIsYawning.self
        action = SKAction.repeatForever(SKAction.animate(with: ["kaki1", "kaki2"].map { self.textures.textureNamed($0) }, timePerFrame: self.timePerFrame))
    }
}
