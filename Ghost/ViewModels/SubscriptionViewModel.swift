//
//  SubscriptionViewModel.swift
//  Ghost
//
//  Created by Артем Гаврилов on 21.01.26.
//

import Foundation
import RevenueCat

@MainActor
final class SubscriptionViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isPurchasing = false
    @Published var hasActiveSubscription = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var selectedPlan: SubscriptionPlan = .yearly
    @Published var monthlyPrice = "$9.99"
    @Published var yearlyPrice = "$49.99"
    
    private let subscriptionService = SubscriptionService.shared
    
    enum SubscriptionPlan {
        case monthly
        case yearly
    }
    
    init() {
        checkSubscriptionStatus()
    }
    
    func loadOfferings() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let offerings = try await Purchases.shared.offerings()
            
            if let packages = offerings.current?.availablePackages {
                for package in packages {
                    let product = package.storeProduct
                    // Use localizedPriceString which is available in iOS
                    let formattedPrice = product.localizedPriceString
                    
                    // Determine subscription type by identifier
                    if package.storeProduct.productIdentifier.contains("month") || 
                       package.storeProduct.productIdentifier.contains("monthly") {
                        monthlyPrice = formattedPrice
                    } else if package.storeProduct.productIdentifier.contains("year") || 
                              package.storeProduct.productIdentifier.contains("yearly") {
                        yearlyPrice = formattedPrice
                    }
                }
            }
        } catch {
            errorMessage = "Failed to load offerings: \(error.localizedDescription)"
            showError = true
        }
    }
    
    func purchaseSubscription() async {
        guard !isPurchasing else { return }
        
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            let offerings = try await Purchases.shared.offerings()
            guard let currentOffering = offerings.current else {
                errorMessage = "Offerings are not available"
                showError = true
                return
            }
            
            // Выбираем пакет в зависимости от выбранного плана
            let package: Package?
            switch selectedPlan {
            case .monthly:
                package = currentOffering.monthly ?? currentOffering.availablePackages.first
            case .yearly:
                package = currentOffering.annual ?? currentOffering.availablePackages.first(where: { $0.storeProduct.productIdentifier.contains("year") })
            }
            
            guard let selectedPackage = package else {
                errorMessage = "Selected plan is not available"
                showError = true
                return
            }
            
            let (_, customerInfo, _) = try await Purchases.shared.purchase(package: selectedPackage)
            
            // Покупка успешна
            subscriptionService.updateSubscriptionStatus(customerInfo)
            hasActiveSubscription = subscriptionService.hasActiveSubscription()
        } catch {
            // Проверяем, не была ли покупка отменена пользователем
            if let purchasesError = error as? Error {
                let errorCode = (purchasesError as NSError).code
                // ErrorCode.purchaseCancelledError has code 1
                if errorCode != 1 {
                    errorMessage = "Purchase error: \(error.localizedDescription)"
                    showError = true
                }
            } else {
                errorMessage = "Purchase error: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            subscriptionService.updateSubscriptionStatus(customerInfo)
            hasActiveSubscription = subscriptionService.hasActiveSubscription()
            
            if !hasActiveSubscription {
                errorMessage = "No active subscriptions found"
                showError = true
            }
        } catch {
            errorMessage = "Restore error: \(error.localizedDescription)"
            showError = true
        }
    }
    
    private func checkSubscriptionStatus() {
        hasActiveSubscription = subscriptionService.hasActiveSubscription()
    }
}
