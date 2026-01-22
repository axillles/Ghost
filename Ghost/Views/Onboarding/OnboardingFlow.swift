//
//  OnboardingFlow.swift
//  Ghost
//
//  Created by Артем Гаврилов on 21.01.26.
//

import SwiftUI

struct OnboardingFlow: View {
    @State private var currentPage = 0
    @State private var canSwipeFromPage0 = false // Можно ли свайпать с 1-го экрана
    @State private var canSwipeFromPage1 = false // Можно ли свайпать со 2-го экрана
    @StateObject private var audioManager = AudioManager.shared
    var onComplete: () -> Void
    
    var body: some View {
        TabView(selection: $currentPage) {
            Screen1(currentPage: $currentPage)
                .tag(0)
            Screen2(currentPage: $currentPage)
                .tag(1)
            Screen3(currentPage: $currentPage)
                .tag(2)
            Screen4(currentPage: $currentPage, canSwipe: $canSwipeFromPage1)
                .tag(3)
                .simultaneousGesture(
                    canSwipeFromPage1 ? nil : DragGesture()
                )
            Screen5(currentPage: $currentPage, canSwipe: $canSwipeFromPage0)
                .tag(4)
                .simultaneousGesture(
                    canSwipeFromPage0 ? nil : DragGesture()
                )
            Screen6(currentPage: $currentPage, onComplete: {
                // Останавливаем музыку перед завершением onboarding
                audioManager.stopOnboardingMusic()
                onComplete()
            })
                .tag(5)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .onAppear {
            // Запускаем зацикленную музыку при появлении onboarding
            audioManager.playOnboardingMusic()
        }
        .onDisappear {
            // Останавливаем музыку при закрытии onboarding
            audioManager.stopOnboardingMusic()
        }
    }
}

#Preview {
    OnboardingFlow(onComplete: {})
}
