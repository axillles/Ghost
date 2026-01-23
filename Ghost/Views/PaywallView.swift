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
            // Обновляем статус подписки после закрытия paywall
            Task {
                do {
                    let customerInfo = try await Purchases.shared.customerInfo()
                    SubscriptionService.shared.updateSubscriptionStatus(customerInfo)
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
        // Проверяем доступность offerings
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
}

#Preview {
    PaywallView(isPresented: .constant(true), mainViewModel: MainViewModel())
}
