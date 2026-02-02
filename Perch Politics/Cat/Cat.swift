//
//  CatConfig.swift
//  Perch Politics
//
//  Created by William Gruszka on 1/2/2026.
//  Copyright © 2026 Matusalem Marques. All rights reserved.
//

import AppKit
import SpriteKit
import GameplayKit

final class Cat {
    let catIdentity: CatIdentity
    let stateMachine: GKStateMachine
    let timer: Timer

    init(
        catIdentity: CatIdentity,
        stateMachine: GKStateMachine,
        timer: Timer
    ) {
        self.catIdentity = catIdentity
        self.stateMachine = stateMachine
        self.timer = timer
    }

    deinit {
        timer.invalidate()
    }
}
