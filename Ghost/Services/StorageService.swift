//
//  StorageService.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import Foundation

final class StorageService {
    static let shared = StorageService()
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "userSettings"
    
    private init() {}
    
    func saveSettings(_ settings: UserSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
        }
    }
    
    func loadSettings() -> UserSettings {
        guard let data = userDefaults.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(UserSettings.self, from: data) else {
            return UserSettings()
        }
        return settings
    }
}
