//
//  EMFService.swift
//  Ghost
//
//  Created by Артем Гаврилов on 21.01.26.
//

import Foundation
import SwiftUI
import Combine

final class EMFService: ObservableObject {
    static let shared = EMFService()
    
    @Published var currentValue: Double = 0
    
    private var timer: Timer?
    private var currentTime: Double = 0
    private var currentPattern: Int = 0
    private let cycleDuration: Double = 120.0
    
    // Переменные для отслеживания состояния в хаотичных фазах
    private var lastChaosUpdateTime: Double = 0
    private var chaosTarget: Double = 0
    
    // Переменные для паттернов
    private var patternDurations: [Double] = [120.0, 40.0, 40.0, 45.0, 35.0, 45.0] // Длительность каждого паттерна
    
    private init() {
        // Не запускаем автоматически, только по запросу
    }
    
    func startSensor() {
        stopSensor()
        currentTime = 0
        currentPattern = Int.random(in: 0...5)
        
        // Инициализируем состояние для хаотичной фазы, если мы в ней
        lastChaosUpdateTime = 0
        chaosTarget = 0
        
        // Сразу обновляем значение для текущего времени
        updateReading()
        
        // Обновляем 20 раз в секунду для плавности и постоянного дрожания
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateReading()
        }
    }
    
    func stopSensor() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateReading() {
        currentTime += 0.05
        let patternDuration = patternDurations[currentPattern]
        
        if currentTime >= patternDuration {
            currentTime = 0
            // Переключаемся на случайный паттерн (не повторяя текущий)
            var newPattern = Int.random(in: 0...5)
            if newPattern == currentPattern {
                newPattern = Int.random(in: 0...5)
            }
            currentPattern = newPattern
            // Сбрасываем состояние
            lastChaosUpdateTime = 0
            chaosTarget = 0
        }
        
        var targetBase: Double = 0
        var noiseLevel: Double = 0
        let t = currentTime
        
        // MARK: - ВЫБОР ПАТТЕРНА
        
        switch currentPattern {
        case 0:
            calculatePattern0(t: t, targetBase: &targetBase, noiseLevel: &noiseLevel)
        case 1:
            calculatePattern1(t: t, targetBase: &targetBase, noiseLevel: &noiseLevel)
        case 2:
            calculatePattern2(t: t, targetBase: &targetBase, noiseLevel: &noiseLevel)
        case 3:
            calculatePattern3(t: t, targetBase: &targetBase, noiseLevel: &noiseLevel)
        case 4:
            calculatePattern4(t: t, targetBase: &targetBase, noiseLevel: &noiseLevel)
        case 5:
            calculatePattern5(t: t, targetBase: &targetBase, noiseLevel: &noiseLevel)
        default:
            targetBase = 0
            noiseLevel = 0
        }
        
        // MARK: - Применение шума и сглаживание
        
        // Генерация случайного дрожания
        let jitter = Double.random(in: -noiseLevel...noiseLevel)
        let noisyTarget = targetBase + jitter
        
        let clampedTarget = min(max(noisyTarget, 0), 300)
        
        // Плавное движение к цели (Lerp).
        let smoothingFactor = 0.2
        currentValue = currentValue + (clampedTarget - currentValue) * smoothingFactor
    }
    
    // MARK: - Паттерн 0: Основной (Ложная безопасность + Агрессивный всплеск)
    private func calculatePattern0(t: Double, targetBase: inout Double, noiseLevel: inout Double) {
        if t < 28.0 {
            // --- Фаза 1: «Ложная безопасность» (0:00 – 0:28) ---
            if t < 7.0 {
                // 0:00 – 0:07: Плавный подъем от 0 до 20. Шум: ±2.
                let progress = t / 7.0
                targetBase = 0 + (progress * 20.0)
                noiseLevel = 2.0
            } else if t < 25.0 {
                // 0:07 – 0:25: Медленный дрейф 30–45. Шум: ±3.
                // Используем синус для ленивого покачивания
                targetBase = 37.5 + sin(t * 0.5) * 7.5
                noiseLevel = 3.0
            } else {
                // 0:25 – 0:28: Медленно опускается до 15. Шум: ±1.
                let progress = (t - 25.0) / 3.0
                // Интерполяция от текущего дрейфа вниз к 15
                targetBase = 35.0 - (progress * 20.0)
                noiseLevel = 1.0
            }
            
        } else if t < 45.0 {
            // --- Фаза 2: «АГРЕССИВНЫЙ ВСПЛЕСК» (0:29 – 0:45) ---
            if t < 30.0 {
                 // 0:29 – 0:30: Мгновенный рывок на 290. Шум: ±20.
                targetBase = 290
                noiseLevel = 20.0
            } else if t < 35.0 {
                // 0:30 – 0:35: Хаотичные прыжки 250 -> 280 -> 220. Шум: ±15.
                if t < 31.5 { targetBase = 250 }
                else if t < 33.5 { targetBase = 280 }
                else { targetBase = 220 }
                noiseLevel = 15.0
            } else {
                // 0:35 – 0:45: Резкое падение и отскоки 110 -> 160 -> 80.
                if t < 37.0 { targetBase = 110 }
                else if t < 40.0 { targetBase = 160 }
                else { targetBase = 80 }
                // Шум постепенно снижается после удара
                noiseLevel = 15.0 - ((t - 35.0) * 1.0)
            }
            
        } else if t < 90.0 {
            // --- Фаза 3: «Нестабильный след» (0:45 – 1:30) ---
            // Каждые 2-3 секунды меняем Target Base случайно в диапазоне 50–180.
            if chaosTarget == 0 || t - lastChaosUpdateTime > Double.random(in: 2.0...3.0) {
                chaosTarget = Double.random(in: 50...180)
                lastChaosUpdateTime = t
            }
            targetBase = chaosTarget
            noiseLevel = Double.random(in: 5...8) // Средний шум
            
        } else if t < 110.0 {
            // --- Фаза 4: «Вторая волна (Эхо)» (1:30 – 1:50) ---
            if t < 100.0 {
                // 1:30 – 1:40: Рост до 190. Шум нарастает до ±10.
                let progress = (t - 90.0) / 10.0
                targetBase = 80 + (progress * 110.0) // от 80 до 190
                noiseLevel = 5.0 + (progress * 5.0)
            } else {
               // 1:40 – 1:50: Держится на 180–190.
               targetBase = 185 + sin(t * 2) * 5
               noiseLevel = 10.0
            }
            
        } else {
            // --- Фаза 5: «Финал» (1:50 – 2:00) ---
            // Плавное снижение до 50. Шум: ±2.
            let progress = (t - 110.0) / 10.0
            targetBase = 185 - (progress * 135.0) // от 185 вниз к 50
            noiseLevel = 2.0
        }
    }
    
    // MARK: - Паттерн 1: Сердцебиение (The Heartbeat)
    private func calculatePattern1(t: Double, targetBase: inout Double, noiseLevel: inout Double) {
        if t < 5.0 {
            // 0:00 – 0:05: Тишина. Target Base: 20. Jitter: ±3.
            targetBase = 20.0
            noiseLevel = 3.0
        } else if t < 8.0 {
            // 0:05 – 0:08: Удар 1. Резкий скачок до 150 и мгновенный возврат к 40.
            if t < 5.2 {
                targetBase = 150.0
                noiseLevel = 10.0
            } else {
                targetBase = 40.0
                noiseLevel = 4.0
            }
        } else if t < 15.0 {
            // 0:08 – 0:15: Пауза. Дрейф 40 -> 30.
            let progress = (t - 8.0) / 7.0
            targetBase = 40.0 - (progress * 10.0)
            noiseLevel = 4.0
        } else if t < 19.0 {
            // 0:15 – 0:19: Удар 2 — Сильнее. Рывок до 240 и возврат к 60.
            if t < 15.2 {
                targetBase = 240.0
                noiseLevel = 25.0
            } else {
                targetBase = 60.0
                noiseLevel = 5.0
            }
        } else if t < 30.0 {
            // 0:19 – 0:30: Аритмия. Быстрые короткие скачки.
            let phase = (t - 19.0).truncatingRemainder(dividingBy: 2.0)
            if phase < 0.4 {
                targetBase = 60.0
            } else if phase < 0.8 {
                targetBase = 110.0
            } else if phase < 1.2 {
                targetBase = 50.0
            } else if phase < 1.6 {
                targetBase = 120.0
            } else {
                targetBase = 40.0
            }
            noiseLevel = 15.0
        } else {
            // 0:30 – 0:40: Затухание. Медленное сползание с 40 до 10.
            let progress = (t - 30.0) / 10.0
            targetBase = 40.0 - (progress * 30.0)
            noiseLevel = 2.0
        }
    }
    
    // MARK: - Паттерн 2: Сбой оборудования (Malfunction)
    private func calculatePattern2(t: Double, targetBase: inout Double, noiseLevel: inout Double) {
        if t < 2.0 {
            // 0:00 – 0:02: Включение. 10 -> 50.
            let progress = t / 2.0
            targetBase = 10.0 + (progress * 40.0)
            noiseLevel = 5.0
        } else if t < 12.0 {
            // 0:02 – 0:12: Шок. Мгновенно 295. Jitter: ±30.
            targetBase = 295.0
            noiseLevel = 30.0
        } else if t < 20.0 {
            // 0:12 – 0:20: Провал. Резкое падение до 15.
            targetBase = 15.0
            noiseLevel = 1.0
        } else if t < 35.0 {
            // 0:20 – 0:35: Помехи. Хаотично меняется каждые 2 секунды.
            let phase = Int((t - 20.0) / 2.0) % 4
            switch phase {
            case 0: targetBase = 50.0
            case 1: targetBase = 180.0
            case 2: targetBase = 20.0
            default: targetBase = 140.0
            }
            noiseLevel = 10.0
        } else {
            // 0:35 – 0:40: Конец. 0.
            targetBase = 0.0
            noiseLevel = 1.0
        }
    }
    
    // MARK: - Паттерн 3: Нарастающая угроза (Slow Burn)
    private func calculatePattern3(t: Double, targetBase: inout Double, noiseLevel: inout Double) {
        if t < 15.0 {
            // 0:00 – 0:15: Разгон. Плавный подъем от 0 до 100.
            let progress = t / 15.0
            targetBase = progress * 100.0
            noiseLevel = 2.0 + (progress * 6.0) // от ±2 до ±8
        } else if t < 25.0 {
            // 0:15 – 0:25: Напряжение. Подъем от 100 до 220.
            let progress = (t - 15.0) / 10.0
            targetBase = 100.0 + (progress * 120.0)
            noiseLevel = 8.0 + (progress * 7.0) // от ±8 до ±15
        } else if t < 35.0 {
            // 0:25 – 0:35: Пик. Очень медленно ползет 220 -> 280.
            let progress = (t - 25.0) / 10.0
            targetBase = 220.0 + (progress * 60.0)
            noiseLevel = 20.0
        } else {
            // 0:35 – 0:45: Обрыв. Остается на 280–290 и бешено вибрирует.
            targetBase = 280.0 + sin(t * 10) * 5.0
            noiseLevel = 20.0
        }
    }
    
    // MARK: - Паттерн 4: Волна (Passing Through)
    private func calculatePattern4(t: Double, targetBase: inout Double, noiseLevel: inout Double) {
        if t < 10.0 {
            // 0:00 – 0:10: Приближение. Подъем 30 -> 120.
            let progress = t / 10.0
            targetBase = 30.0 + (progress * 90.0)
            noiseLevel = 5.0
        } else if t < 15.0 {
            // 0:10 – 0:15: Контакт. Быстрый рост 120 -> 260.
            let progress = (t - 10.0) / 5.0
            targetBase = 120.0 + (progress * 140.0)
            noiseLevel = 25.0
        } else if t < 20.0 {
            // 0:15 – 0:20: Эпицентр. Держится в диапазоне 250–270.
            targetBase = 260.0 + sin(t * 2) * 10.0
            noiseLevel = 10.0
        } else if t < 30.0 {
            // 0:20 – 0:30: Удаление. Плавный спуск 250 -> 80.
            let progress = (t - 20.0) / 10.0
            targetBase = 250.0 - (progress * 170.0)
            noiseLevel = 8.0 - (progress * 3.0) // от ±8 до ±5
        } else {
            // 0:30 – 0:35: Эхо. Небольшой подскок 80 -> 110 -> 40.
            if t < 32.0 {
                let progress = (t - 30.0) / 2.0
                targetBase = 80.0 + (progress * 30.0)
            } else {
                let progress = (t - 32.0) / 3.0
                targetBase = 110.0 - (progress * 70.0)
            }
            noiseLevel = 5.0
        }
    }
    
    // MARK: - Паттерн 5: Фоновый шум (High Noise)
    private func calculatePattern5(t: Double, targetBase: inout Double, noiseLevel: inout Double) {
        if t < 10.0 {
            // 0:00 – 0:10: Target Base: 40. Jitter: ±20.
            targetBase = 40.0
            noiseLevel = 20.0
        } else if t < 25.0 {
            // 0:10 – 0:25: Медленно поднимается до 110. Jitter: ±35.
            let progress = (t - 10.0) / 15.0
            targetBase = 40.0 + (progress * 70.0)
            noiseLevel = 35.0
        } else if t < 30.0 {
            // 0:25 – 0:30: Резко падает на 50. Jitter резко уменьшается до ±2.
            targetBase = 50.0
            noiseLevel = 2.0
        } else if t < 35.0 {
            // 0:30 – 0:35: Target Base: 60. Jitter: снова всплеск ±25.
            targetBase = 60.0
            noiseLevel = 25.0
        } else {
            // 0:35 – 0:45: Target Base: 20. Jitter: ±5.
            targetBase = 20.0
            noiseLevel = 5.0
        }
    }
}
