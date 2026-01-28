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
        currentPattern = Int.random(in: 1...10)
    }
    
    func setSensitivity(_ value: Double) {
        sensitivity = value
    }
    
    func startRadar() {
        stopRadar()
        currentTime = 0
        currentPattern = Int.random(in: 1...10)
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
            newPattern = Int.random(in: 1...10)
            if newPattern == currentPattern {
                newPattern = Int.random(in: 1...10)
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
            
        case 6: // Сбой матрицы (Scatter & Converge)
            // Взрыв и разлет (2.0 - 10.0)
            if t >= 2.0 && t <= 10.0 {
                let scatterProgress = (t - 2.0) / 8.0
                
                // Точка 1: к углу 15, радиус 90%
                let angle1 = 75.0 + (15.0 - 75.0) * scatterProgress
                let radius1 = 60.0 + (90.0 - 60.0) * scatterProgress
                newDots.append(GhostDot(position: getPosition(angle: angle1, radiusPercent: radius1), intensity: 1.0))
                
                // Точка 2: к углу 160, радиус 80%
                let angle2 = 75.0 + (160.0 - 75.0) * scatterProgress
                let radius2 = 60.0 + (80.0 - 60.0) * scatterProgress
                newDots.append(GhostDot(position: getPosition(angle: angle2, radiusPercent: radius2), intensity: 1.0))
                
                // Точка 3: к углу 255, радиус 95%
                let angle3 = 75.0 + (255.0 - 75.0) * scatterProgress
                let radius3 = 60.0 + (95.0 - 60.0) * scatterProgress
                newDots.append(GhostDot(position: getPosition(angle: angle3, radiusPercent: radius3), intensity: 1.0))
                
                // Точка 4: вибрирует на месте (до 12.0)
                if t < 12.0 {
                    let jitter = sin(t * 20) * 2
                    let jitterRadius = 2.0 * cos(t * 15)
                    newDots.append(GhostDot(position: getPosition(angle: 75 + jitter, radiusPercent: 60 + jitterRadius), intensity: 1.0))
                }
            }
            
            // Атака к центру (15.0 - 32.0) с зигзагом
            if t >= 15.0 && t <= 32.0 {
                let attackProgress = (t - 15.0) / 17.0
                let zigzag = sin(attackProgress * 6 * .pi) * 0.3 // Зигзаг эффект
                
                // Точка 1 (была на 15)
                let targetRadius1 = 15.0 + (90.0 - 15.0) * (1.0 - attackProgress)
                let zigzagAngle1 = 15.0 + zigzag * 10
                newDots.append(GhostDot(position: getPosition(angle: zigzagAngle1, radiusPercent: targetRadius1), intensity: 1.0))
                
                // Точка 2 (была на 160)
                let targetRadius2 = 20.0 + (80.0 - 20.0) * (1.0 - attackProgress)
                let zigzagAngle2 = 160.0 + zigzag * 10
                newDots.append(GhostDot(position: getPosition(angle: zigzagAngle2, radiusPercent: targetRadius2), intensity: 1.0))
                
                // Точка 3 (была на 255)
                let targetRadius3 = 18.0 + (95.0 - 18.0) * (1.0 - attackProgress)
                let zigzagAngle3 = 255.0 + zigzag * 10
                newDots.append(GhostDot(position: getPosition(angle: zigzagAngle3, radiusPercent: targetRadius3), intensity: 1.0))
            }
            
            // Вспышка в центре (38.0)
            if t >= 38.0 && t < 39.0 {
                newDots.append(GhostDot(position: getPosition(angle: 0, radiusPercent: 5), intensity: 1.0))
            }
            
        case 7: // Блуждающий огонь (Wandering Wisp)
            // Появление и дрейф (0.0 - 10.0)
            if t >= 0.0 && t <= 10.0 {
                let driftProgress = t / 10.0
                let angle = 233.0 + (190.0 - 233.0) * driftProgress
                let radius = 88.0 - (88.0 - 60.0) * driftProgress
                let wave = sin(t * 2) * 5 // Волнистая линия
                newDots.append(GhostDot(position: getPosition(angle: angle + wave, radiusPercent: radius), intensity: 1.0))
            }
            
            // Испуг (10.0 - 10.5)
            if t >= 10.0 && t <= 10.5 {
                let jumpProgress = (t - 10.0) / 0.5
                let angle = 190.0 + (250.0 - 190.0) * jumpProgress
                let radius = 60.0 + (95.0 - 60.0) * jumpProgress
                newDots.append(GhostDot(position: getPosition(angle: angle, radiusPercent: radius), intensity: 1.0))
            }
            
            // Любопытство (12.0 - 25.0) - короткие перебежки
            if t >= 12.0 && t <= 25.0 {
                let phase = (t - 12.0).truncatingRemainder(dividingBy: 4.0)
                var angle = 250.0
                var radius = 95.0
                
                // Используем детерминированное значение вместо random для стабильности
                let chaos = sin(t * 3.7) * 20.0
                
                if phase < 2.0 {
                    // Рывок к центру
                    let rushProgress = phase / 2.0
                    angle = 250.0 + chaos
                    radius = 95.0 - (95.0 - 70.0) * rushProgress
                } else if phase < 3.0 {
                    // Пауза
                    angle = 250.0 + chaos
                    radius = 70.0
                } else {
                    // Смещение вбок
                    let sideProgress = (phase - 3.0) / 1.0
                    angle = 250.0 + chaos + sideProgress * 10
                    radius = 70.0
                }
                newDots.append(GhostDot(position: getPosition(angle: angle, radiusPercent: radius), intensity: 1.0))
            }
            
            // Появление точки Б (25.0)
            if t >= 25.0 && t <= 31.0 {
                newDots.append(GhostDot(position: getPosition(angle: 55, radiusPercent: 40), intensity: 1.0))
                
                // Точка А летит к точке Б (27.0 - 30.0)
                if t >= 27.0 && t <= 30.0 {
                    let flyProgress = (t - 27.0) / 3.0
                    let angleA = 250.0 + (60.0 - 250.0) * flyProgress
                    let radiusA = 70.0 + (45.0 - 70.0) * flyProgress
                    newDots.append(GhostDot(position: getPosition(angle: angleA, radiusPercent: radiusA), intensity: 1.0))
                }
            }
            
        case 8: // Осада (The Siege)
            // Появление 3 точек на периметре (1.0)
            if t >= 1.0 {
                // Точка А (Угол 10)
                var angleA = 10.0
                var radiusA = 90.0
                
                // Точка Б (Угол 130)
                var angleB = 130.0
                var radiusB = 90.0
                
                // Точка В (Угол 260)
                var angleC = 260.0
                var radiusC = 90.0
                
                // Маятник (5.0 - 25.0)
                if t >= 5.0 && t <= 25.0 {
                    let pendulumPhase = (t - 5.0) / 20.0
                    let swing = sin(pendulumPhase * 4 * .pi) * 20.0
                    let breathing = sin(pendulumPhase * 2 * .pi) * 5.0
                    
                    angleA = 10.0 + swing
                    radiusA = 90.0 + breathing
                    
                    angleB = 130.0 - swing * 0.7 // Несинхронное движение
                    radiusB = 90.0 + breathing * 0.8
                    
                    angleC = 260.0 + swing * 0.5
                    radiusC = 90.0 - breathing * 0.6
                }
                
                if t < 35.0 {
                    newDots.append(GhostDot(position: getPosition(angle: angleA, radiusPercent: radiusA), intensity: 1.0))
                    newDots.append(GhostDot(position: getPosition(angle: angleB, radiusPercent: radiusB), intensity: 1.0))
                    newDots.append(GhostDot(position: getPosition(angle: angleC, radiusPercent: radiusC), intensity: 1.0))
                }
                
                // Внутренние точки Г и Д (26.0)
                if t >= 26.0 {
                    var angleD = 80.0
                    var angleE = 200.0
                    var radiusDE = 30.0
                    
                    // Быстрое вращение (28.0 - 35.0)
                    if t >= 28.0 && t <= 35.0 {
                        let rotationSpeed = (t - 28.0) * 20.0
                        angleD = 80.0 + rotationSpeed
                        angleE = 200.0 + rotationSpeed
                    }
                    
                    if t < 40.0 {
                        newDots.append(GhostDot(position: getPosition(angle: angleD, radiusPercent: radiusDE), intensity: 1.0))
                        newDots.append(GhostDot(position: getPosition(angle: angleE, radiusPercent: radiusDE), intensity: 1.0))
                    }
                    
                    // Внешние точки летят к внутренним (35.0 - 38.0)
                    if t >= 35.0 && t <= 38.0 {
                        let convergeProgress = (t - 35.0) / 3.0
                        
                        let finalAngleA = 10.0 + (80.0 - 10.0) * convergeProgress
                        let finalRadiusA = 90.0 - (90.0 - 30.0) * convergeProgress
                        newDots.append(GhostDot(position: getPosition(angle: finalAngleA, radiusPercent: finalRadiusA), intensity: 1.0))
                        
                        let finalAngleB = 130.0 + (80.0 - 130.0) * convergeProgress
                        let finalRadiusB = 90.0 - (90.0 - 30.0) * convergeProgress
                        newDots.append(GhostDot(position: getPosition(angle: finalAngleB, radiusPercent: finalRadiusB), intensity: 1.0))
                        
                        let finalAngleC = 260.0 + (200.0 - 260.0) * convergeProgress
                        let finalRadiusC = 90.0 - (90.0 - 30.0) * convergeProgress
                        newDots.append(GhostDot(position: getPosition(angle: finalAngleC, radiusPercent: finalRadiusC), intensity: 1.0))
                    }
                }
            }
            
        case 9: // Пьяный мастер (Drunken Path)
            // Точка А: спираль (0.0 - 9.0)
            if t >= 0.0 && t <= 9.0 {
                let spiralProgress = t / 9.0
                var angle = 312.0 + spiralProgress * 360.0 * 2 // Два оборота
                var radius = 20.0 + spiralProgress * 50.0
                
                // "Битая" спираль - иногда радиус уменьшается
                if Int(t * 2) % 3 == 0 {
                    radius -= 5.0
                }
                
                newDots.append(GhostDot(position: getPosition(angle: angle, radiusPercent: radius), intensity: 1.0))
            }
            
            // Точки Б и В появляются (10.0)
            if t >= 10.0 {
                var angleB = 44.0
                var angleC = 167.0
                var radiusBC = 80.0
                
                // Взаимное притяжение по дуге (12.0 - 25.0)
                if t >= 12.0 && t <= 25.0 {
                    let attractProgress = (t - 12.0) / 13.0
                    let meetingAngle = 100.0
                    
                    // Движение по дуге к центру
                    let arcB = (44.0 - meetingAngle) * (1.0 - attractProgress)
                    let arcC = (167.0 - meetingAngle) * (1.0 - attractProgress)
                    
                    angleB = 44.0 - arcB
                    angleC = 167.0 - arcC
                    
                    // Радиус уменьшается (дуга к центру)
                    radiusBC = 80.0 - attractProgress * 30.0
                    
                    // Ускорение после встречи (20.0+)
                    if t >= 20.0 {
                        let speedBoost = (t - 20.0) * 2.0
                        angleB -= speedBoost
                        angleC += speedBoost
                        radiusBC += speedBoost * 2.0
                    }
                }
                
                if t <= 40.0 {
                    newDots.append(GhostDot(position: getPosition(angle: angleB, radiusPercent: radiusBC), intensity: 1.0))
                    newDots.append(GhostDot(position: getPosition(angle: angleC, radiusPercent: radiusBC), intensity: 1.0))
                }
                
                // Точки Г и Д (22.0)
                if t >= 22.0 {
                    var angleD = 280.0
                    var angleE = 290.0
                    var radiusDE = 80.0
                    
                    // Прыжки и сползание вниз (25.0 - 40.0)
                    if t >= 25.0 && t <= 40.0 {
                        let jumpPhase = (t - 25.0) / 15.0
                        let jumpOffset = sin(jumpPhase * 10 * .pi) * 10.0
                        let radiusJump = cos(jumpPhase * 8 * .pi) * 5.0
                        
                        angleD = 280.0 + jumpOffset + jumpPhase * 30.0 // Сползание вниз
                        angleE = 290.0 + jumpOffset + jumpPhase * 30.0
                        radiusDE = 80.0 + radiusJump - jumpPhase * 20.0
                    }
                    
                    newDots.append(GhostDot(position: getPosition(angle: angleD, radiusPercent: radiusDE), intensity: 1.0))
                    newDots.append(GhostDot(position: getPosition(angle: angleE, radiusPercent: radiusDE), intensity: 1.0))
                }
            }
            
        case 10: // Мерцающий наблюдатель (The Blink)
            // Первое появление (1.0 - 3.0)
            if t >= 1.0 && t < 3.0 {
                newDots.append(GhostDot(position: getPosition(angle: 212, radiusPercent: 90), intensity: 1.0))
            }
            
            // Второе появление (4.0 - 5.5)
            if t >= 4.0 && t < 5.5 {
                newDots.append(GhostDot(position: getPosition(angle: 47, radiusPercent: 85), intensity: 1.0))
            }
            
            // Третье появление (6.0 - 7.0)
            if t >= 6.0 && t < 7.0 {
                newDots.append(GhostDot(position: getPosition(angle: 305, radiusPercent: 60), intensity: 1.0))
            }
            
            // Стробоскоп (8.0 - 18.0)
            if t >= 8.0 && t <= 18.0 {
                let strobePhase = (t - 8.0).truncatingRemainder(dividingBy: 1.0)
                if strobePhase < 0.5 {
                    let strobeIndex = Int((t - 8.0) / 1.0) % 4
                    switch strobeIndex {
                    case 0:
                        newDots.append(GhostDot(position: getPosition(angle: 15, radiusPercent: 50), intensity: 1.0))
                    case 1:
                        newDots.append(GhostDot(position: getPosition(angle: 195, radiusPercent: 55), intensity: 1.0))
                    case 2:
                        newDots.append(GhostDot(position: getPosition(angle: 88, radiusPercent: 40), intensity: 1.0))
                    case 3:
                        newDots.append(GhostDot(position: getPosition(angle: 260, radiusPercent: 45), intensity: 1.0))
                    default:
                        break
                    }
                }
            }
            
            // Скример (23.0 - 23.3)
            if t >= 23.0 && t < 23.3 {
                newDots.append(GhostDot(position: getPosition(angle: 355, radiusPercent: 10), intensity: 1.0))
            }
            
            // Вспышка за спиной (24.0 - 24.3)
            if t >= 24.0 && t < 24.3 {
                newDots.append(GhostDot(position: getPosition(angle: 175, radiusPercent: 15), intensity: 1.0))
            }
            
            // Хаотичный дождь (25.0 - 35.0)
            if t >= 25.0 && t <= 35.0 {
                let cycle = Int((t - 25.0) / 2.0) % 2
                let phase = (t - 25.0).truncatingRemainder(dividingBy: 2.0)
                
                if phase < 1.0 {
                    if cycle == 0 {
                        newDots.append(GhostDot(position: getPosition(angle: 20, radiusPercent: 70), intensity: 1.0))
                        newDots.append(GhostDot(position: getPosition(angle: 140, radiusPercent: 75), intensity: 1.0))
                        newDots.append(GhostDot(position: getPosition(angle: 300, radiusPercent: 80), intensity: 1.0))
                    } else {
                        newDots.append(GhostDot(position: getPosition(angle: 55, radiusPercent: 30), intensity: 1.0))
                        newDots.append(GhostDot(position: getPosition(angle: 200, radiusPercent: 40), intensity: 1.0))
                        newDots.append(GhostDot(position: getPosition(angle: 340, radiusPercent: 50), intensity: 1.0))
                    }
                }
            }
            
            // Финальная точка (38.0 - 45.0)
            if t >= 38.0 && t <= 45.0 {
                let alpha = t > 42.0 ? (45.0 - t) / 3.0 : 1.0
                newDots.append(GhostDot(position: getPosition(angle: 123, radiusPercent: 95), intensity: alpha))
            }
            
        default:
            break
        }
        
        self.dots = newDots
    }
}
