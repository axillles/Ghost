//
//  GhostApp.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI

@main
struct GhostApp: App {
    @State private var showOnboarding = !OnboardingService.shared.hasCompletedOnboarding()
    @State private var showSubscription = false
    
    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingFlow(onComplete: {
                    showOnboarding = false
                    // Показываем экран подписок через 5 секунд после завершения онбординга
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        // Показываем только если нет активной подписки
                        if !SubscriptionService.shared.hasActiveSubscription() {
                            showSubscription = true
                        }
                    }
                })
            } else {
                MainView()
                    .sheet(isPresented: $showSubscription) {
                        SubscriptionView(isPresented: $showSubscription, mainViewModel: MainViewModel())
                    }
            }
        }
    }
}
