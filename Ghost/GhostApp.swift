//
//  GhostApp.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI
import FirebaseCore

@main
struct GhostApp: App {
    @State private var showOnboarding = !OnboardingService.shared.hasCompletedOnboarding()
    @State private var showSubscription = false
    
    init() {
        // Инициализация Firebase
        FirebaseApp.configure()
        
        // Отслеживаем первый запуск приложения
        checkAndLogFirstOpen()
    }
    
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
    
    /// Проверяет и логирует первый запуск приложения
    private func checkAndLogFirstOpen() {
        let hasLoggedFirstOpen = UserDefaults.standard.bool(forKey: "has_logged_first_open")
        
        if !hasLoggedFirstOpen {
            AnalyticsService.shared.logFirstOpen()
            UserDefaults.standard.set(true, forKey: "has_logged_first_open")
        }
    }
}
