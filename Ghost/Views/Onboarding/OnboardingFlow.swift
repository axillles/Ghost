//
//  OnboardingFlow.swift
//  Ghost
//
//  Created by Артем Гаврилов on 21.01.26.
//

import SwiftUI
import UIKit

struct OnboardingFlow: View {
    @State private var currentPage = 0
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
                onComplete()
            })
                .tag(5)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .onAppear {
            disableSwipeInTabView()
        }
        .onChange(of: currentPage) { _ in
            disableSwipeInTabView()
        }
    }
    
    private func disableSwipeInTabView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                disableSwipeInView(rootViewController.view)
            }
        }
    }
    
    private func disableSwipeInView(_ view: UIView) {
        if let scrollView = view as? UIScrollView {
            scrollView.isScrollEnabled = false
        }
        for subview in view.subviews {
            disableSwipeInView(subview)
        }
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
