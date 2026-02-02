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

    var atlasName: String {
        switch self {
        case .cat1: return "Black Cat"
        case .cat2: return "White Cat"
        }
    }

    var name: String { rawValue }
}
