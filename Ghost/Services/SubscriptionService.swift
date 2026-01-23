//
//  SubscriptionService.swift
//  Ghost
//
//  Created by Артем Гаврилов on 21.01.26.
//

import Foundation
import RevenueCat

final class SubscriptionService {
    static let shared = SubscriptionService()
    
    private let storage = StorageService.shared
    
    private init() {
        configureRevenueCat()
    }
    
    private func configureRevenueCat() {
        // Revenue Cat API key (тестовый или продакшн)
        // Get it from Revenue Cat Dashboard: https://app.revenuecat.com
        let apiKey = "test_aRwiKWuLDbfaYDatarwVPIEpRgM"
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey)
        
        print("✅ Revenue Cat configured with API key: \(apiKey.prefix(10))...")
        
        // Set user identifier (optional)
        // Purchases.shared.logIn("user_id") { customerInfo, created, error in }
    }
    
    func hasActiveSubscription() -> Bool {
        let settings = storage.loadSettings()
        return settings.hasUnlockedPremium
    }
    
    func updateSubscriptionStatus(_ customerInfo: CustomerInfo) {
        let hasActiveEntitlement = customerInfo.entitlements.active.count > 0
        
        var settings = storage.loadSettings()
        settings.hasUnlockedPremium = hasActiveEntitlement
        storage.saveSettings(settings)
    }
    
    func checkSubscriptionStatus() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            updateSubscriptionStatus(customerInfo)
            return hasActiveSubscription()
        } catch {
            print("Subscription check error: \(error.localizedDescription)")
            return false
        }
    }
}
