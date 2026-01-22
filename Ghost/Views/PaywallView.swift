//
//  PaywallView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI

struct PaywallView: View {
    @StateObject private var viewModel = PaywallViewModel()
    @Binding var isPresented: Bool
    @ObservedObject var mainViewModel: MainViewModel
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                
                Text("Разблокировать Premium")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 15) {
                    FeatureRow(icon: "sparkles", text: "Все функции разблокированы")
                    FeatureRow(icon: "waveform", text: "Расширенный радар")
                    FeatureRow(icon: "sensor.tag.radiowaves.forward", text: "Продвинутый магнитометр")
                    FeatureRow(icon: "speaker.wave.3", text: "Эксклюзивные звуки")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(action: {
                        viewModel.purchasePremium()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            mainViewModel.settings = StorageService.shared.loadSettings()
                            isPresented = false
                        }
                    }) {
                        Text(viewModel.isPurchasing ? "Обработка..." : "Купить Premium")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.isPurchasing)
                    
                    Button(action: {
                        viewModel.restorePurchases()
                    }) {
                        Text("Восстановить покупки")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Позже")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}


#Preview {
    PaywallView(isPresented: .constant(true), mainViewModel: MainViewModel())
}
