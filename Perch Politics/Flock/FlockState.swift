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
    unowned let flockContext: FlockContext  // unowned to avoid retain cycles
    
    init(flockContext: FlockContext) {
        self.flockContext = flockContext
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard stateMachine != nil else { return }
        
        let perchPosition = flockContext.activeWindowGeometry ?? flockContext.dockGeometry ?? (32, 0, 0)
        let distance = hypot(perchPosition.leftX - 32 - flockContext.destination.x, perchPosition.topY - flockContext.destination.y)
        
        if (distance >= 32) { // TODO: set this as a const and use in the bird states too
            flockContext.birdSettledOrder = [:]
        }
        
        if (perchPosition.leftX - 32 != flockContext.destination.x || perchPosition.topY != flockContext.destination.y) {
            flockContext.destination = NSPoint(x: perchPosition.leftX - 32, y: perchPosition.topY)
        }
    }
}
