//
//  MagnetometerService.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import Foundation
import Combine

final class MagnetometerService: ObservableObject {
    static let shared = MagnetometerService()
    
    @Published var reading = MagnetometerReading(value: 0.0, candleIntensity: 0.0)
    
    private var timer: Timer?
    
    private init() {
        startMagnetometer()
    }
    
    func startMagnetometer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateReading()
        }
    }
    
    func stopMagnetometer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateReading() {
        // Симулируем случайные показания магнитометра
        let baseValue = Double.random(in: -100...100)
        let variation = sin(Date().timeIntervalSince1970 * 2) * 20
        
        let value = baseValue + variation
        let normalizedValue = abs(value) / 100.0
        let candleIntensity = min(normalizedValue, 1.0)
        
        reading = MagnetometerReading(value: value, candleIntensity: candleIntensity)
    }
}
