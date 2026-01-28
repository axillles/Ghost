//
//  OnboardingService.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import Foundation

final class OnboardingService {
    static let shared = OnboardingService()
    
    private let storage = StorageService.shared
    
    private init() {}
    
    func hasCompletedOnboarding() -> Bool {
        return storage.loadSettings().hasCompletedOnboarding
    }
    
    func completeOnboarding() {
        var settings = storage.loadSettings()
        settings.hasCompletedOnboarding = true
        storage.saveSettings(settings)
    }
    
    func resetOnboarding() {
        var settings = storage.loadSettings()
        settings.hasCompletedOnboarding = false
        storage.saveSettings(settings)
    }
}
