//
//  GhostDetection.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import Foundation
import CoreGraphics

struct GhostDot: Identifiable {
    let id = UUID()
    var position: CGPoint
    var intensity: Double
    var age: TimeInterval
}

struct MagnetometerReading {
    var value: Double
    var candleIntensity: Double
}
