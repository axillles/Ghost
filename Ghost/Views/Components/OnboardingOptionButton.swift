//
//  OnboardingOptionButton.swift
//  Ghost
//
//  Created by Артем Гаврилов on 21.01.26.
//

import Foundation
import SwiftUI

struct OptionButton: View {
    let emoji: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Text(emoji)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(nil)  // ← Добавьте это!
                }
                .frame(maxWidth: .infinity, alignment: .leading)  // ← И это!
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                        .frame(width: 30, height: 30)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(hex: "7AFD91"))
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 25)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(20)
        }
    }
}

#Preview {
    OnboardingFlow()
}
