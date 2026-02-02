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

final class CatInstance {
    let cat: Cat
    let stateMachine: GKStateMachine
    let timer: Timer

    init(
        cat: Cat,
        stateMachine: GKStateMachine,
        timer: Timer
    ) {
        self.cat = cat
        self.stateMachine = stateMachine
        self.timer = timer
    }

    deinit {
        timer.invalidate()
    }
}
