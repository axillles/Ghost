//
//  OnboardingViewModel.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    
    let pages = [
        OnboardingPage(
            title: "Добро пожаловать",
            description: "Откройте для себя мир призраков с помощью нашего детектора",
            imageName: "sparkles"
        ),
        OnboardingPage(
            title: "Радар призраков",
            description: "Используйте радар для обнаружения призрачных сущностей",
            imageName: "waveform"
        ),
        OnboardingPage(
            title: "Магнитометр",
            description: "Измеряйте электромагнитные поля с помощью встроенного магнитометра",
            imageName: "sensor.tag.radiowaves.forward"
        )
    ]
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        }
    }
    
    func complete() {
        OnboardingService.shared.completeOnboarding()
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}
