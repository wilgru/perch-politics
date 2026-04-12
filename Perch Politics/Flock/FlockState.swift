//
//  FlockState.swift
//  Perch Politics
//
//  Created by William Gruszka on 2/2/2026.
//  Copyright © 2026 Matusalem Marques. All rights reserved.
//

import Foundation
import GameplayKit

final class FlockState: GKState {
    weak let flock: Flock?  // weak to avoid retain cycles
    
    init(flock: Flock) {
        self.flock = flock
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard stateMachine != nil else { return }
        guard let flock = flock else { return }
        
        let perchPosition = flock.activeWindowGeometry ?? flock.dockGeometry ?? NSPoint(x: 32, y: 0)
        let distance = hypot(perchPosition.x - 32 - flock.destination.x, perchPosition.y - flock.destination.y)
        
        if (distance >= 32) { // TODO: set this as a const and use in the bird states too
            for bird in flock.birds {
                bird.settledOrder = nil
            }
        }
        
        if (perchPosition.x - 32 != flock.destination.x || perchPosition.y != flock.destination.y) {
            flock.destination = NSPoint(x: perchPosition.x - 32, y: perchPosition.y - 6)
        }
    }
}
