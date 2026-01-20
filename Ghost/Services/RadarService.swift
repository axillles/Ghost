//
//  RadarService.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import Foundation
import CoreGraphics
import Combine

final class RadarService: ObservableObject {
    static let shared = RadarService()
    
    @Published var dots: [GhostDot] = []
    
    private var timer: Timer?
    private var sensitivity: Double = 0.5
    
    private init() {
        startRadar()
    }
    
    func setSensitivity(_ value: Double) {
        sensitivity = value
    }
    
    func startRadar() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateRadar()
        }
    }
    
    func stopRadar() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateRadar() {
        // Удаляем старые точки
        dots = dots.filter { $0.age < 3.0 }
        
        // Обновляем возраст существующих точек
        dots = dots.map { dot in
            var updated = dot
            updated.age += 0.1
            return updated
        }
        
        // Создаем новые точки случайным образом
        let spawnChance = sensitivity * 0.3
        if Double.random(in: 0...1) < spawnChance {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = Double.random(in: 0.2...0.9)
            let x = 0.5 + cos(angle) * distance * 0.4
            let y = 0.5 + sin(angle) * distance * 0.4
            
            let dot = GhostDot(
                position: CGPoint(x: x, y: y),
                intensity: Double.random(in: 0.3...1.0),
                age: 0
            )
            dots.append(dot)
        }
    }
}
