//
//  MainViewModel.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import Foundation
import Combine

@MainActor
final class MainViewModel: ObservableObject {
    @Published var settings: UserSettings
    @Published var showPaywall = false
    
    private let storage = StorageService.shared
    private let audioService = AudioService.shared
    private let audioManager = AudioManager.shared
    private let radarService = RadarService.shared
    private var cancellables = Set<AnyCancellable>()
    private var soundTimer: Timer?
    
    init() {
        settings = storage.loadSettings()
        radarService.setSensitivity(settings.radarSensitivity)
        // Применяем настройки к обоим аудио сервисам
        audioService.volume = settings.volume
        audioManager.volume = settings.volume
        // Если звуки выключены, останавливаем музыку
        if !settings.soundEnabled {
            audioManager.stop()
        }
        startRandomSounds()
    }
    
    func startRandomSounds() {
        guard settings.soundEnabled else { return }
        
        soundTimer?.invalidate()
        scheduleNextSound()
    }
    
    private func scheduleNextSound() {
        soundTimer?.invalidate()
        let delay = Double.random(in: 3...8)
        soundTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            guard let self = self, self.settings.soundEnabled else { return }
            self.audioService.playRandomSound()
            self.scheduleNextSound()
        }
    }
    
    func stopRandomSounds() {
        soundTimer?.invalidate()
        soundTimer = nil
        // Полностью останавливаем все случайные звуки
        audioService.stopAllSounds()
    }
    
    func toggleSound() {
        settings.soundEnabled.toggle()
        storage.saveSettings(settings)
        
        if settings.soundEnabled {
            startRandomSounds()
        } else {
            stopRandomSounds()
        }
    }
    
    // Новый метод для установки конкретного значения
    func setSoundEnabled(_ enabled: Bool) {
        settings.soundEnabled = enabled
        storage.saveSettings(settings)
        
        if enabled {
            startRandomSounds()
            // Музыка будет включена автоматически через onChange в MainView
        } else {
            stopRandomSounds()
            // Выключаем всю музыку в приложении
            audioManager.stop()
        }
    }
    
    func updateSensitivity(_ value: Double) {
        settings.radarSensitivity = value
        storage.saveSettings(settings)
        radarService.setSensitivity(value)
    }
    
    func updateVolume(_ value: Double) {
        settings.volume = value
        storage.saveSettings(settings)
        // Обновляем громкость во всех аудио сервисах
        audioService.volume = value
        audioManager.volume = value
    }
    
    func showPaywallIfNeeded() {
        if !settings.hasUnlockedPremium {
            showPaywall = true
        }
    }
}
