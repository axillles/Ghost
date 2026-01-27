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
    private let cycleDuration: Double = 120.0
    
    // Переменные для отслеживания состояния в хаотичных фазах
    private var lastChaosUpdateTime: Double = 0
    private var chaosTarget: Double = 0
    
    private init() {
        // Не запускаем автоматически, только по запросу
    }
    
    func startSensor() {
        stopSensor()
        currentTime = 0
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
        if currentTime >= cycleDuration { currentTime = 0 } // Зацикливаем
        
        var targetBase: Double = 0
        var noiseLevel: Double = 0
        let t = currentTime
        
        // MARK: - СЦЕНАРИЙ ПОВЕДЕНИЯ
        
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
            if t - lastChaosUpdateTime > Double.random(in: 2.0...3.0) {
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
        
        // MARK: - Применение шума и сглаживание
        
        // Генерация случайного дрожания
        let jitter = Double.random(in: -noiseLevel...noiseLevel)
        let noisyTarget = targetBase + jitter
        
        let clampedTarget = min(max(noisyTarget, 0), 300)
        
        // Плавное движение к цели (Lerp).
        let smoothingFactor = 0.2
        currentValue = currentValue + (clampedTarget - currentValue) * smoothingFactor
    }
}
