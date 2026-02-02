//
//  FlockContext.swift
//  Perch Politics
//
//  Created by William Gruszka on 2/2/2026.
//  Copyright © 2026 Matusalem Marques. All rights reserved.
//

import Foundation
import GameplayKit

final class FlockContext {
    var destination: NSPoint = .zero
    var birdPositions: [CatIdentity: NSPoint] = [:]
    var birdSettledOrder: [CatIdentity: Int] = [:]
    
    var cohesionStrength: CGFloat = 1.0
    var separationStrength: CGFloat = 1.0
    var alignmentStrength: CGFloat = 1.0
    
    var velocity: CGVector = .zero
    var center: NSPoint {
        let positions = self.birdPositions.map { $0.value }
        return positions.reduce(NSPoint.zero) { partialResult, point in
            NSPoint(x: partialResult.x + point.x, y: partialResult.y + point.y)
        }
    }
    
    var activeWindowGeometry: (
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
        print("Could not find a window to get geometry for")
        return nil
    }
    
    var dockGeometry: (
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
            topY: Double(topY)
        )
    }
}
