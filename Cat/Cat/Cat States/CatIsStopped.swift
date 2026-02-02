//
//  CatIsStopped.swift
//  Cat
//
//  Created by Matusalem Marques on 2017/02/28.
//

import SpriteKit
import GameplayKit

class CatIsStopped : CatState {
    override init(catIdentity: CatIdentity, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, flockContext: FlockContext) {
        super.init(catIdentity: catIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        validNextStates = [ CatIsAwake.self, CatIsLicking.self ]
        nextState = CatIsLicking.self
        action = SKAction.setTexture(self.textures.textureNamed("mati2"))
    }
}
