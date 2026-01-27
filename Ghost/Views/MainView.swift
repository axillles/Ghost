//
//  MainView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI

enum Tab: Int, CaseIterable {
    case radar = 0
    case emf = 1
    case spiritBox = 2
    case settings = 3
    
    var title: String {
        switch self {
        case .radar: return "Radar"
        case .emf: return "EMF"
        case .spiritBox: return "Spirit Box"
        case .settings: return "Settings"
        }
    }
    
    var imageName: String {
        switch self {
        case .radar: return "Tab_radar"
        case .emf: return "Tab_emf"
        case .spiritBox: return "Tab_spirit"
        case .settings: return "Tab_settings"
        }
    }
}

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @ObservedObject private var cameraService = CameraService.shared
    @ObservedObject private var audioManager = AudioManager.shared
    @State private var selectedTab: Tab = .radar
    
    var body: some View {
        ZStack {
            if cameraService.isAuthorized {
                CameraPreview(session: cameraService.session)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .radar:
                        RadarScreen()
                    case .emf:
                        EMFScreen()
                    case .spiritBox:
                        SpiritBoxView()
                    case .settings:
                        SettingsView(viewModel: viewModel)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView(isPresented: $viewModel.showPaywall, mainViewModel: viewModel)
        }
        .onAppear {
            if !cameraService.isAuthorized {
                cameraService.checkPermission()
            }
            updateAudioForTab(selectedTab)
        }
        .onChange(of: selectedTab) { newTab in
            updateAudioForTab(newTab)
        }
        .onChange(of: viewModel.settings.soundEnabled) { enabled in
            if enabled {
                DispatchQueue.main.async {
                    self.updateAudioForTab(self.selectedTab)
                }
            } else {
                audioManager.stop()
            }
        }
    }
    
    private func updateAudioForTab(_ tab: Tab) {
        switch tab {
        case .radar:
            // Звук радара управляется из RadarView через кнопку START/STOP
            // Не включаем звук автоматически при переходе на экран радара
            break
        case .emf:
            if viewModel.settings.soundEnabled {
                audioManager.playForMode(.emf)
                viewModel.startRandomSounds()
            } else {
                audioManager.stop()
                viewModel.stopRandomSounds()
            }
        case .spiritBox:
            if viewModel.settings.soundEnabled {
                audioManager.playForMode(.spirit)
                viewModel.startRandomSounds()
            } else {
                audioManager.stop()
                viewModel.stopRandomSounds()
            }
        case .settings:
            audioManager.stop()
            viewModel.stopRandomSounds()
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 6) {
                        Image(tab.imageName)
                            .resizable()
                            .frame(width: 28, height: 28)
                            .opacity(selectedTab == tab ? 1.0 : 0.5)
                        
                        Text(tab.title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(selectedTab == tab ? Color(hex: "7AFD91") : Color.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color.black)
        .padding(.bottom, 0)
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
