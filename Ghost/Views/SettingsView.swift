//
//  SettingsView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                Text("SETTINGS")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "7AFD91"))
                    .padding(.top, 20)
                
                // Settings sections
                VStack(spacing: 25) {
                    // Sound toggle
                    SettingsRow(
                        icon: viewModel.settings.soundEnabled ? "speaker.wave.3.fill" : "speaker.slash.fill",
                        title: "Sound",
                        value: viewModel.settings.soundEnabled ? "ON" : "OFF"
                    ) {
                        viewModel.toggleSound()
                    }
                    
                    // Sensitivity slider
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(Color(hex: "7AFD91"))
                                .frame(width: 30)
                            Text("Sensitivity")
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(Int(viewModel.settings.radarSensitivity * 100))%")
                                .foregroundColor(Color(hex: "7AFD91"))
                        }
                        
                        Slider(
                            value: Binding(
                                get: { viewModel.settings.radarSensitivity },
                                set: { viewModel.updateSensitivity($0) }
                            ),
                            in: 0...1
                        )
                        .tint(Color(hex: "7AFD91"))
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Premium section
                    if !viewModel.settings.hasUnlockedPremium {
                        Button(action: {
                            viewModel.showPaywall = true
                        }) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                Text("Unlock Premium")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.yellow, Color.orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                    } else {
                        SettingsRow(
                            icon: "crown.fill",
                            title: "Premium",
                            value: "ACTIVE"
                        ) {}
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView(isPresented: $viewModel.showPaywall, mainViewModel: viewModel)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "7AFD91"))
                    .frame(width: 30)
                Text(title)
                    .foregroundColor(.white)
                Spacer()
                Text(value)
                    .foregroundColor(Color(hex: "7AFD91"))
                    .font(.system(size: 14, weight: .medium))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    SettingsView()
        .background(Color.black)
}
