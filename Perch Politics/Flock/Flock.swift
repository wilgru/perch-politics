//
//  Flock.swift
//  Perch Politics
//
//  Created by William Gruszka on 2/2/2026.
//  Copyright © 2026 Matusalem Marques. All rights reserved.
//

import Foundation
import GameplayKit

final class Flock {
    var birds: [Bird] = []
    var spawnedBirds: [Bird] {
        birds.filter { bird in
            bird.spawned
        }
    }
    var settledBirdsCount: Int {
        get {
            birds.count { bird in
                bird.settledOrder != nil
            }
        }
    }
    
    var destination: NSPoint = .zero
    var cohesionStrength: CGFloat = 0.01
    var separationStrength: CGFloat = 2

    private func getFlockmates(for givenBird: Bird) -> [Bird] {
        spawnedBirds.filter { bird in
            bird !== givenBird
        }
    }
    
    func spawnBird(birdIdentity: BirdIdentity) {
        let foundBird = birds.first { bird in
            bird.birdIdentity == birdIdentity
        }
        foundBird?.spawn()
    }
//    
//    func despawnBird(birdIdentity: BirdIdentity) {
//        let foundBird = birds.first { bird in
//            bird.birdIdentity == birdIdentity
//        }
//        
//        foundBird?.despawn()
//    }
    
    // Returns a velocity adjustment vector steering toward the center of mass of local flockmates (cohesion)
    func cohesionVelocity(for givenBird: Bird) -> NSPoint {
        let flockmates = getFlockmates(for: givenBird) // flockmates being the other birds that isnt the given bird
        guard !flockmates.isEmpty else { return .zero }
        
        // Calculate center of mass
        let birdPositionsSum = flockmates.reduce(NSPoint.zero) { sum, flockmate in
            return NSPoint(x: sum.x + flockmate.position.x, y: sum.y + flockmate.position.y)
        }
        let count = CGFloat(flockmates.count)
        let centerPoint = NSPoint(x: birdPositionsSum.x / count, y: birdPositionsSum.y / count)
        
        // Steer towards the center
        let steer = NSPoint(x: (centerPoint.x - givenBird.position.x) * cohesionStrength, y: (centerPoint.y - givenBird.position.y) * cohesionStrength)
        return steer
    }

    // Returns a velocity adjustment vector steering away from close flockmates (separation)
    func separationVelocity(for givenBird: Bird) -> NSPoint {
        var repulsion = NSPoint.zero
        for flockmate in getFlockmates(for: givenBird) {
            let distanceX = givenBird.position.x - flockmate.position.x
            let distanceY = givenBird.position.y - flockmate.position.y
            let distanceSquared = distanceX * distanceX + distanceY * distanceY
            
            if distanceSquared > 0 {
                // The closer they are, the stronger the repulsion
                repulsion.x += distanceX / distanceSquared
                repulsion.y += distanceY / distanceSquared
            }
        }
        
        return NSPoint(x: repulsion.x * separationStrength, y: repulsion.y * separationStrength)
    }
    
    var activeWindowGeometry: ( // TODO: just retrun NSPoint
        leftX: Double,
        rightX: Double,
        topY: Double
    )? {
        let options = CGWindowListOption.optionOnScreenOnly
        guard let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: AnyObject]] else {
            print("Could not get window list")
            return nil
        }
        
        guard let screenHeight = NSScreen.main?.frame.height else {
            print("Could not find main screen")
            return nil
        }

        guard let frontAppPID = NSWorkspace.shared.frontmostApplication?.processIdentifier else {
            print("Could not find front app PID")
            return nil
        }
        
        for window in windowList {
            if let windowPID = window[kCGWindowOwnerPID as String] as? Int,
               let boundsAny = window[kCGWindowBounds as String],
               let layer = window[kCGWindowLayer as String] as? Int,
                   windowPID == frontAppPID,
                   layer == 0 // layer 0 for normal windows
                {
                if CFGetTypeID(boundsAny as CFTypeRef) == CFDictionaryGetTypeID() {
                    guard let bounds = CGRect(dictionaryRepresentation: boundsAny as! CFDictionary) else {
                        print("Could not convert type of bounds to CFDictionary")
                        return nil
                    }
                    
                    return (
                        leftX: Double(bounds.origin.x + 32 + 30), //30 for corner radius
                        rightX:  Double(bounds.origin.x + bounds.size.width - 32),
                        topY:  Double(screenHeight - bounds.origin.y)
                    )
                }
            }
        }
//        print("Could not find a window to get geometry for")
        return nil
    }
    
    var dockGeometry: ( // TODO: just retrun NSPoint
        leftX: Double,
        rightX: Double,
        topY: Double
    )? {
        guard let screen = NSScreen.main else {
            print("Could not get main screen when getting dock")
            return nil
        }

        let frame = screen.frame
        let visible = screen.visibleFrame

        // Dock must be at the bottom - if dock is on the side, autohidden or not present, return nil
        guard visible.minY > frame.minY else {
            return nil
        }

        let centerX = frame.midX
        let topY = visible.minY

        return (
            leftX: Double(centerX),
            rightX: Double(centerX),
            topY: Double(topY - 1) // the dock seems to have a 1px padding, so subtracting 1 to account for that
        )
    }
}
