//
//  Constants.swift
//  Perch Politics
//

import Foundation

// MARK: timer interval and flight tunings
// Flight tuning values are tuned against the timerInterval. If timerInterval changes, these should be recalculated together.

// 8 Hz interval
//let timerInterval: TimeInterval = 1.0 / 8.0
//let birdFlightSpeed: CGFloat = 16.0
//let birdFlightVelocityDampen: CGFloat = 0.80
//let birdFlockCohesionStrength: CGFloat = 0.01
//let birdFlockSeparationStrength: CGFloat = 2.0

// 16 Hz interval
let timerInterval: TimeInterval = 1.0 / 16.0
let birdFlightSpeed: CGFloat = 8.0
let birdFlightVelocityDampen: CGFloat = 0.85
let birdFlockCohesionStrength: CGFloat = 0.005
let birdFlockSeparationStrength: CGFloat = 1.0
