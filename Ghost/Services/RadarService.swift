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
    @Published var isActive: Bool = false
    
    private var timer: Timer?
    private var currentTime: Double = 0
    private var currentPattern: Int = 1
    private let cycleDuration: Double = 45.0
    private var sensitivity: Double = 0.5
    
    private init() {
        currentPattern = Int.random(in: 1...5)
    }
    
    func setSensitivity(_ value: Double) {
        sensitivity = value
    }
    
    func startRadar() {
        stopRadar()
        currentTime = 0
        currentPattern = Int.random(in: 1...5)
        isActive = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateRadar()
        }
    }
    
    func stopRadar() {
        timer?.invalidate()
        timer = nil
        dots = []
        isActive = false
    }
    
    private func updateRadar() {
        currentTime += 0.1
        var newPattern: Int
        if currentTime >= cycleDuration {
            currentTime = 0
            newPattern = Int.random(in: 1...5)
            if newPattern == currentPattern {
                newPattern = Int.random(in: 1...5)
            }
            currentPattern = newPattern
        }
        
        if currentTime < 6.0 {
            dots = []
            return
        }
        
        calculatePatternState()
    }
    
    // MARK: - Расчет координат
    // Угол 0 = 12 часов
    // Корректируем: вычитаем 90 градусов.
    private func getPosition(angle: Double, radiusPercent: Double) -> CGPoint {
        let radius = (radiusPercent / 100.0) * 0.5 // 0.5 так как центр в 0.5
        let radians = (angle - 90) * .pi / 180
        let x = 0.5 + cos(radians) * radius
        let y = 0.5 + sin(radians) * radius
        return CGPoint(x: x, y: y)
    }
    
    private func calculatePatternState() {
        var newDots: [GhostDot] = []
        let t = currentTime
        
        switch currentPattern {
        case 1: // Преследование
            if t >= 6.0 && t <= 45.0 {
                let progress = min((t - 6.0) / 30.0, 1.0)
                var angle = 190.0
                let radius = 95.0 - (progress * 75.0)
                
                if t >= 36.0 { angle = 220.0 }
                
                let alpha = t > 43.0 ? (45.0 - t) / 2.0 : 1.0
                newDots.append(GhostDot(position: getPosition(angle: angle, radiusPercent: radius), intensity: alpha))
            }
            if t >= 15.0 && t <= 20.0 {
                newDots.append(GhostDot(position: getPosition(angle: 90, radiusPercent: 60), intensity: 1.0))
            }
            
        case 2: // Треугольник
            let rotation = t >= 15.0 ? (t - 15.0) * 2.0 : 0.0
            
            if t >= 5.0 && t <= 28.0 {
                newDots.append(GhostDot(position: getPosition(angle: 0 + rotation, radiusPercent: 70), intensity: 1.0))
            }
            if t >= 7.0 && t <= 30.0 {
                newDots.append(GhostDot(position: getPosition(angle: 120 + rotation, radiusPercent: 70), intensity: 1.0))
            }
            if t >= 10.0 && t <= 35.0 {
                var r = 70.0
                if t > 32.0 { r += (t - 32.0) * 30.0 }
                newDots.append(GhostDot(position: getPosition(angle: 240 + rotation, radiusPercent: r), intensity: 1.0))
            }
            
        case 3: // Транзит
            if t >= 7.0 && t <= 30.0 {
                let progress = (t - 7.0) / 23.0
                let currentXPercent = -90.0 + (progress * 180.0)
                let angle = currentXPercent < 0 ? 270.0 : 90.0
                let radius = abs(currentXPercent)
                newDots.append(GhostDot(position: getPosition(angle: angle, radiusPercent: radius), intensity: 1.0))
            }
            if t >= 18.0 && t <= 35.0 {
                if Int(t * 10) % 40 < 20 {
                    newDots.append(GhostDot(position: getPosition(angle: 40, radiusPercent: 50), intensity: 1.0))
                }
            }
            
        case 4: // Глючный сигнал
            if t >= 6.0 && t < 12.0 {
                newDots.append(GhostDot(position: getPosition(angle: 330, radiusPercent: 60), intensity: 1.0))
            } else if t >= 14.0 && t < 20.0 {
                newDots.append(GhostDot(position: getPosition(angle: 350, radiusPercent: 50), intensity: 1.0))
            } else if t >= 23.0 && t < 35.0 {
                newDots.append(GhostDot(position: getPosition(angle: 10, radiusPercent: 30), intensity: 1.0))
            }
            
            if t >= 25.0 && t <= 42.0 {
                let jitter = sin(t * 10) * 10
                let alpha = t > 35.0 ? (42.0 - t) / 7.0 : 1.0
                newDots.append(GhostDot(position: getPosition(angle: 180 + jitter, radiusPercent: 80), intensity: alpha))
            }
            
        case 5: // Близнецы
            if t >= 5.0 && t <= 40.0 {
                var r = 50.0
                if t >= 15.0 && t <= 25.0 {
                    r = 50.0 + ((t - 15.0) / 10.0) * 40.0
                } else if t > 25.0 {
                    r = 90.0
                }
                
                let alpha = t > 35.0 ? (40.0 - t) / 5.0 : 1.0
                newDots.append(GhostDot(position: getPosition(angle: 130, radiusPercent: r), intensity: alpha))
                newDots.append(GhostDot(position: getPosition(angle: 140, radiusPercent: r), intensity: alpha))
            }
            if t >= 27.0 && t <= 35.0 {
                newDots.append(GhostDot(position: getPosition(angle: 300, radiusPercent: 20), intensity: 1.0))
            }
            
        default:
            break
        }
        
        self.dots = newDots
    }
}
