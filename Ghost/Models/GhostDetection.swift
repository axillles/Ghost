//
//  GhostDetection.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import Foundation
import CoreGraphics

struct GhostDot: Identifiable {
    let id: UUID
    var position: CGPoint // Координаты от 0 до 1
    var intensity: Double // Яркость (0..1)
    
    init(id: UUID = UUID(), position: CGPoint, intensity: Double) {
        self.id = id
        self.position = position
        self.intensity = intensity
    }
}

struct MagnetometerReading {
    var value: Double
    var candleIntensity: Double
}
