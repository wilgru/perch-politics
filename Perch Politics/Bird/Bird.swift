//
//  Bird.swift
//  Perch Politics
//
//  Created by William Gruszka on 1/2/2026.
//  Copyright © 2026 Matusalem Marques. All rights reserved.
//

import AppKit
import SpriteKit
import GameplayKit

final class Bird {
    let birdIdentity: BirdIdentity
    let stateMachine: GKStateMachine
    let timer: Timer

    init(
        birdIdentity: BirdIdentity,
        stateMachine: GKStateMachine,
        timer: Timer
    ) {
        self.birdIdentity = birdIdentity
        self.stateMachine = stateMachine
        self.timer = timer
    }

    deinit {
        timer.invalidate()
    }
}
