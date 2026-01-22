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
        // TODO: Replace with your Revenue Cat API key
        // Get it from Revenue Cat Dashboard: https://app.revenuecat.com
        let apiKey = "test_aRwiKWuLDbfaYDatarwVPIEpRgM"
        
        // Check if API key has been updated
        guard apiKey != "test_aRwiKWuLDbfaYDatarwVPIEpRgM" else {
            print("⚠️ Revenue Cat API key not configured! Please update SubscriptionService.swift")
            return
        }
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey)
        
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
