//
//  Cat.swift
//  Perch Politics
//
//  Created by William Gruszka on 1/2/2026.
//  Copyright © 2026 Matusalem Marques. All rights reserved.
//

enum CatIdentity: String, CaseIterable {
    case cat1 = "Cat 1"
    case cat2 = "Cat 2"
    case cat3 = "Cat 3"
    case cat4 = "Cat 4"

    var atlasName: String {
        switch self {
        case .cat1: return "Black Cat"
        case .cat2: return "White Cat"
        case .cat3: return "White Cat"
        case .cat4: return "Black Cat"
        }
    }

    var name: String { rawValue }
}
