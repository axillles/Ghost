//
//  UserSettings.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import Foundation

struct UserSettings: Codable {
    var hasCompletedOnboarding: Bool
    var hasUnlockedPremium: Bool
    var soundEnabled: Bool
    var radarSensitivity: Double
    var volume: Double
    
    init() {
        self.hasCompletedOnboarding = false
        self.hasUnlockedPremium = false
        self.soundEnabled = true
        self.radarSensitivity = 0.5
        self.volume = 0.5
    }
}
