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
    private let subscriptionService = SubscriptionService.shared
    
    private init() {}
    
    func hasUnlockedPremium() -> Bool {
        return subscriptionService.hasActiveSubscription()
    }
    
    func unlockPremium() {
        var settings = storage.loadSettings()
        settings.hasUnlockedPremium = true
        storage.saveSettings(settings)
    }
}
