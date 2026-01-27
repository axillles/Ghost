//
//  OnboardingFlow.swift
//  Ghost
//
//  Created by Артем Гаврилов on 21.01.26.
//

import SwiftUI

struct OnboardingFlow: View {
    @State private var currentPage = 0
    @StateObject private var audioManager = AudioManager.shared
    var onComplete: () -> Void
    
    var body: some View {
        TabView(selection: $currentPage) {
            Screen1(currentPage: createBinding(for: 0))
                .tag(0)
            Screen2(currentPage: createBinding(for: 1))
                .tag(1)
            Screen3(currentPage: createBinding(for: 2))
                .tag(2)
            Screen4(currentPage: createBinding(for: 3))
                .tag(3)
            Screen5(currentPage: createBinding(for: 4))
                .tag(4)
            Screen6(currentPage: createBinding(for: 5), onComplete: {
                audioManager.stopOnboardingMusic()
                onComplete()
            })
                .tag(5)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .simultaneousGesture(
            DragGesture(minimumDistance: 20)
                .onChanged { _ in }
        )
    }
    
    private func createBinding(for page: Int) -> Binding<Int> {
        Binding(
            get: { currentPage },
            set: { newValue in
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPage = newValue
                }
            }
        )
    }
}
#Preview {
    OnboardingFlow(onComplete: {})
}
