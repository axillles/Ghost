//
//  AnalyticsService.swift
//  Ghost
//
//  Created by Артем Гаврилов on 24.01.26.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    // MARK: - События
    
    /// Отслеживает первый запуск приложения
    func logFirstOpen() {
        Analytics.logEvent("first_open", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
        print("📊 Analytics: first_open logged")
    }
    
    /// Отслеживает начало триала
    func logTrialStart(productId: String? = nil) {
        var parameters: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let productId = productId {
            parameters["product_id"] = productId
        }
        
        Analytics.logEvent("trial_start", parameters: parameters)
        print("📊 Analytics: trial_start logged with product_id: \(productId ?? "unknown")")
    }
    
    /// Отслеживает успешную покупку
    func logPurchase(productId: String? = nil, price: Double? = nil, currency: String? = nil) {
        var parameters: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let productId = productId {
            parameters["product_id"] = productId
        }
        
        if let price = price {
            parameters["value"] = price
        }
        
        if let currency = currency {
            parameters["currency"] = currency
        }
        
        Analytics.logEvent("purchase", parameters: parameters)
        print("📊 Analytics: purchase logged with product_id: \(productId ?? "unknown")")
    }
}
