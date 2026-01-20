//
//  PaywallService.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import Foundation

final class PaywallService {
    static let shared = PaywallService()
    
    private let storage = StorageService.shared
    
    private init() {}
    
    func hasUnlockedPremium() -> Bool {
        return storage.loadSettings().hasUnlockedPremium
    }
    
    func unlockPremium() {
        var settings = storage.loadSettings()
        settings.hasUnlockedPremium = true
        storage.saveSettings(settings)
    }
    
    // Здесь можно добавить интеграцию с StoreKit для реальных покупок
    func purchasePremium() {
        // TODO: Интеграция с StoreKit
        unlockPremium()
    }
}
