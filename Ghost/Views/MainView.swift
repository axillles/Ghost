//
//  MainView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @StateObject private var cameraService = CameraService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Камера как фон
            if cameraService.isAuthorized {
                CameraPreview(session: cameraService.session)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            // Затемнение фона для лучшей видимости UI
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Верхняя панель
                HStack {
                    Button(action: {
                        viewModel.toggleSound()
                    }) {
                        Image(systemName: viewModel.settings.soundEnabled ? "speaker.wave.3.fill" : "speaker.slash.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    if !viewModel.settings.hasUnlockedPremium {
                        Button(action: {
                            viewModel.showPaywall = true
                        }) {
                            Image(systemName: "crown.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                                .padding()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Основной контент
                TabView(selection: $selectedTab) {
                    // Радар
                    RadarView()
                        .tag(0)
                    
                    // Магнитометр
                    MagnetometerView()
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Нижняя панель управления
                VStack(spacing: 15) {
                    // Индикатор выбранного режима
                    HStack(spacing: 20) {
                        Button(action: { selectedTab = 0 }) {
                            VStack {
                                Image(systemName: "waveform")
                                    .font(.title2)
                                Text("Радар")
                                    .font(.caption)
                            }
                            .foregroundColor(selectedTab == 0 ? .green : .gray)
                        }
                        
                        Button(action: { selectedTab = 1 }) {
                            VStack {
                                Image(systemName: "sensor.tag.radiowaves.forward")
                                    .font(.title2)
                                Text("Магнитометр")
                                    .font(.caption)
                            }
                            .foregroundColor(selectedTab == 1 ? .green : .gray)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // Слайдер чувствительности
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Чувствительность")
                            .font(.caption)
                            .foregroundColor(.white)
                        Slider(value: Binding(
                            get: { viewModel.settings.radarSensitivity },
                            set: { viewModel.updateSensitivity($0) }
                        ), in: 0...1)
                        .tint(.green)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                .background(Color.black.opacity(0.6))
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView(isPresented: $viewModel.showPaywall, mainViewModel: viewModel)
        }
        .onAppear {
            cameraService.checkPermission()
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    MainView()
}
