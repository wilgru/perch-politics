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
    let windowController: NSWindowController
    let stateMachine: GKStateMachine
    let timer: Timer

    init(
        windowController: NSWindowController,
        birdIdentity: BirdIdentity,
        stateMachine: GKStateMachine,
        timer: Timer
    ) {
        self.windowController = windowController
        self.birdIdentity = birdIdentity
        self.stateMachine = stateMachine
        self.timer = timer
    }

    deinit {
        timer.invalidate()
        windowController.close()
        // TODO: may also need to remove any refs to this bird in the flock context on destruction
    }
}
