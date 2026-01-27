//
//  PaywallView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct PaywallView: View {
    @Binding var isPresented: Bool
    @ObservedObject var mainViewModel: MainViewModel
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if let error = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                    Text("Ошибка загрузки paywall")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Закрыть") {
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            } else {
                RevenueCatUI.PaywallView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Закрыть") {
                    isPresented = false
                }
            }
        }
        .onAppear {
            loadPaywall()
        }
        .onDisappear {
            Task {
                do {
                    let customerInfo = try await Purchases.shared.customerInfo()
                    let previousStatus = SubscriptionService.shared.hasActiveSubscription()
                    
                    SubscriptionService.shared.updateSubscriptionStatus(customerInfo)
                    
                    let currentStatus = SubscriptionService.shared.hasActiveSubscription()
                    
                    if !previousStatus && currentStatus {
                        if let activeEntitlement = customerInfo.entitlements.active.values.first {
                            let productIdentifier = activeEntitlement.productIdentifier
                            
                            let period = activeEntitlement.periodType
                            
                            if period == .trial {
                                AnalyticsService.shared.logTrialStart(productId: productIdentifier)
                            } else {
                                let offerings = try await Purchases.shared.offerings()
                                if let package = offerings.current?.availablePackages.first(where: { $0.storeProduct.productIdentifier == productIdentifier }) {
                                    let product = package.storeProduct
                                    let price = NSDecimalNumber(decimal: product.price).doubleValue
                                    let currency = extractCurrency(from: product.localizedPriceString) ?? "USD"
                                    
                                    AnalyticsService.shared.logPurchase(
                                        productId: productIdentifier,
                                        price: price,
                                        currency: currency
                                    )
                                } else {
                                    AnalyticsService.shared.logPurchase(productId: productIdentifier)
                                }
                            }
                        }
                    }
                    
                    await MainActor.run {
                        mainViewModel.settings = StorageService.shared.loadSettings()
                    }
                } catch {
                    print("Error checking customer info: \(error)")
                }
            }
        }
    }
    
    private func loadPaywall() {
        Task {
            do {
                let offerings = try await Purchases.shared.offerings()
                await MainActor.run {
                    isLoading = false
                    if offerings.current == nil {
                        errorMessage = "Paywall не настроен в RevenueCat Dashboard. Пожалуйста, настройте paywall в Dashboard."
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Не удалось загрузить конфигурацию: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func extractCurrency(from priceString: String) -> String? {
        if priceString.contains("$") {
            return "USD"
        } else if priceString.contains("€") {
            return "EUR"
        } else if priceString.contains("£") {
            return "GBP"
        } else if priceString.contains("₽") {
            return "RUB"
        }
        return nil
    }
}

#Preview {
    PaywallView(isPresented: .constant(true), mainViewModel: MainViewModel())
}
