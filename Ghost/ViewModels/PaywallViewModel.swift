//
//  PaywallViewModel.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import Foundation

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var isPurchasing = false
    
    private let paywallService = PaywallService.shared
    
    func purchasePremium() {
        isPurchasing = true
        
        // Симуляция покупки
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.paywallService.purchasePremium()
            self?.isPurchasing = false
        }
    }
    
    func restorePurchases() {
        // TODO: Восстановление покупок через StoreKit
    }
}
