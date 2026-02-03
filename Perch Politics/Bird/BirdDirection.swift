//
//  BirdDirection.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/28.
//

import Foundation

enum BirdDirection : Int {
    case left
    case right
    
    init(vector: NSPoint) {
        let angle = Double(atan2(vector.y, vector.x))
        
        switch(angle) {
        case (-7/8 * .pi)...(1/8 * .pi):
            self = .right
        default:
            self = .left
        }
    }
    
    static func squared(vector: NSPoint) -> BirdDirection {
        let angle = Double(atan2(vector.y, vector.x))
        
        switch(angle) {
        case (-3/4 * .pi)...(1/4 * .pi):
            return .right
        default:
            return .left
        }
    }
}
