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
    
    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
            } else {
                MainView()
            }
        }
    }
}
