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
        #if DEBUG
        // Тестовый ключ только для Debug сборок
        let apiKey = "test_aRwiKWuLDbfaYDatarwVPIEpRgM"
        Purchases.logLevel = .debug
        #else
        // Production ключ для Release сборок (TestFlight, App Store)
        // ⚠️ ВАЖНО: Замените на ваш реальный Production API Key из Revenue Cat Dashboard
        // Production ключ начинается с "appl_" или "rcapi_"
        let apiKey = "appl_nnIMawgYMERcywYpCVgAgOYJJrt" // TODO: Замените на реальный production ключ
        Purchases.logLevel = .error // В production используем только ошибки
        #endif
        
        // Проверка, что в Release не используется тестовый ключ
        #if !DEBUG
        if apiKey.hasPrefix("test_") {
            fatalError("❌ КРИТИЧЕСКАЯ ОШИБКА: В Release сборке нельзя использовать тестовый API ключ RevenueCat! Используйте Production API Key.")
        }
        #endif
        
        Purchases.configure(withAPIKey: apiKey)
        
        print("✅ Revenue Cat configured with API key: \(apiKey.prefix(10))...")
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
