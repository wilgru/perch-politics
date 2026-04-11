//
//  BirdIdentity.swift
//  Perch Politics
//
//  Created by William Gruszka on 1/2/2026.
//  Copyright © 2026 Matusalem Marques. All rights reserved.
//

enum BirdIdentity: String, CaseIterable {
    case kyra = "Kyra"
    case greenBub = "Green Bub"
    case fatFeet = "Fat Feet"
    case peg = "Peg"

    var name: String { rawValue }
    
    var atlasName: String {
        switch self {
        case .kyra: return "Kyra"
        case .greenBub: return "Kyra"
        case .fatFeet: return "Kyra"
        case .peg: return "Kyra"
        }
    }
    
    static func from(name: String) -> BirdIdentity? {
        allCases.first { $0.name == name }
    }
}
