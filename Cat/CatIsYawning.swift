//
//  CatIsYawning.swift
//  Cat
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class CatIsYawning : CatState { // akubi
    override init(catIdentity: Cat, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(catIdentity: catIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        validNextStates = [ CatIsAwake.self, CatIsScratching.self, CatIsSleeping.self ]
        nextState = CatIsSleeping.self
        action = SKAction.setTexture(self.textures.textureNamed("mati3"))
    }
}
