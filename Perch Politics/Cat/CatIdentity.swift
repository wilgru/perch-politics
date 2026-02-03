//
//  Cat.swift
//  Perch Politics
//
//  Created by William Gruszka on 1/2/2026.
//  Copyright © 2026 Matusalem Marques. All rights reserved.
//

enum CatIdentity: String, CaseIterable {
    case kyra = "Kyra"
    case greenBub = "Green Bub"
    case fatFeet = "Fat Feet"
    case peg = "Peg"

    var atlasName: String {
        switch self {
        case .kyra: return "Black Cat"
        case .greenBub: return "White Cat"
        case .fatFeet: return "White Cat"
        case .peg: return "Black Cat"
        }
    }

    var name: String { rawValue }
}
