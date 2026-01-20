//
//  SettingsView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var privacyPolicyURL = "https://project14105329.tilda.ws/"
    @State private var termsOfUseURL = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
    @State private var showShareSheet = false
    
    var body: some View {
        ZStack {
            // Фоновое изображение с фиксированным размером экрана
            GeometryReader { geometry in
                Image("settings_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
            
            // Затемнение
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Контент - полностью независим от фона
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    Text("SETTINGS")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "7AFD91"))
                        .padding(.top, 20)
                    
                    // App Settings Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("APP SETTINGS")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "7AFD91"))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 15) {
                            // Sound Effects Switch
                            HStack {
                                Image(systemName: viewModel.settings.soundEnabled ? "speaker.wave.3.fill" : "speaker.slash.fill")
                                    .foregroundColor(Color(hex: "7AFD91"))
                                    .frame(width: 30)
                                Text("Sound Effects")
                                    .foregroundColor(.white)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { viewModel.settings.soundEnabled },
                                    set: { newValue in viewModel.setSoundEnabled(newValue) }
                                ))
                                .tint(Color(hex: "7AFD91"))
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Volume Slider
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .foregroundColor(Color(hex: "7AFD91"))
                                        .frame(width: 30)
                                    Text("Volume")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(Int(viewModel.settings.volume * 100))%")
                                        .foregroundColor(Color(hex: "7AFD91"))
                                        .font(.system(size: 14, weight: .medium))
                                }
                                
                                Slider(
                                    value: Binding(
                                        get: { viewModel.settings.volume },
                                        set: { viewModel.updateVolume($0) }
                                    ),
                                    in: 0...1
                                )
                                .tint(Color(hex: "7AFD91"))
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // About Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("ABOUT")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "7AFD91"))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            // Rate Us
                            SettingsButton(
                                icon: "star.fill",
                                title: "Rate Us"
                            ) {
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                    SKStoreReviewController.requestReview(in: windowScene)
                                }
                            }
                            
                            // Privacy Policy
                            SettingsButton(
                                icon: "lock.shield.fill",
                                title: "Privacy Policy"
                            ) {
                                if let url = URL(string: privacyPolicyURL), !privacyPolicyURL.isEmpty {
                                    UIApplication.shared.open(url)
                                }
                            }
                            
                            // Terms of Use
                            SettingsButton(
                                icon: "doc.text.fill",
                                title: "Terms of Use"
                            ) {
                                if let url = URL(string: termsOfUseURL), !termsOfUseURL.isEmpty {
                                    UIApplication.shared.open(url)
                                }
                            }
                            
                            // Share App
                            SettingsButton(
                                icon: "square.and.arrow.up.fill",
                                title: "Share App"
                            ) {
                                showShareSheet = true
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView(isPresented: $viewModel.showPaywall, mainViewModel: viewModel)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: ["Check out this amazing Ghost Detector app!"])
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct SettingsButton: View {
    let icon: String
    let title: String
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
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 12))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    SettingsView()
}
