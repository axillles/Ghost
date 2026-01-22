//
//  SubscriptionView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 21.01.26.
//

import SwiftUI

struct SubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @Binding var isPresented: Bool
    @ObservedObject var mainViewModel: MainViewModel
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 20) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "7AFD91"))
                    
                    Text("Unlock Premium")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Get access to all features")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
                .padding(.top, 60)
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Features
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(icon: "sparkles", text: "All features unlocked")
                    FeatureRow(icon: "waveform", text: "Advanced radar")
                    FeatureRow(icon: "sensor.tag.radiowaves.forward", text: "Advanced magnetometer")
                    FeatureRow(icon: "speaker.wave.3", text: "Exclusive sounds")
                    FeatureRow(icon: "infinity", text: "Unlimited usage")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Subscription Options
                VStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "7AFD91")))
                            .scaleEffect(1.5)
                            .padding(.vertical, 40)
                    } else {
                        // Yearly Subscription
                        SubscriptionButton(
                            title: "Year",
                            price: viewModel.yearlyPrice,
                            period: "per year",
                            savings: "Save 58%",
                            isRecommended: true,
                            isSelected: viewModel.selectedPlan == .yearly,
                            isLoading: viewModel.isPurchasing && viewModel.selectedPlan == .yearly
                        ) {
                            viewModel.selectedPlan = .yearly
                        }
                        
                        // Monthly Subscription
                        SubscriptionButton(
                            title: "Month",
                            price: viewModel.monthlyPrice,
                            period: "per month",
                            savings: nil,
                            isRecommended: false,
                            isSelected: viewModel.selectedPlan == .monthly,
                            isLoading: viewModel.isPurchasing && viewModel.selectedPlan == .monthly
                        ) {
                            viewModel.selectedPlan = .monthly
                        }
                    }
                    
                    // Purchase Button
                    Button(action: {
                        Task {
                            await viewModel.purchaseSubscription()
                            if viewModel.hasActiveSubscription {
                                mainViewModel.settings = StorageService.shared.loadSettings()
                                isPresented = false
                            }
                        }
                    }) {
                        Text(viewModel.isPurchasing ? "Processing..." : "Continue")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color(hex: "7AFD91"))
                            .cornerRadius(30)
                    }
                    .disabled(viewModel.isPurchasing || viewModel.isLoading)
                    .padding(.top, 8)
                    
                    // Restore Purchases
                    Button(action: {
                        Task {
                            await viewModel.restorePurchases()
                            if viewModel.hasActiveSubscription {
                                mainViewModel.settings = StorageService.shared.loadSettings()
                                isPresented = false
                            }
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 12)
                    
                    // Terms and Privacy
                    HStack(spacing: 20) {
                        Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            Task {
                await viewModel.loadOfferings()
            }
        }
    }
}

struct SubscriptionButton: View {
    let title: String
    let price: String
    let period: String
    let savings: String?
    let isRecommended: Bool
    let isSelected: Bool
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        if isRecommended {
                            Text("RECOMMENDED")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "7AFD91"))
                                .cornerRadius(4)
                        }
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(price)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "7AFD91"))
                        Text(period)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    
                    if let savings = savings {
                        Text(savings)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "7AFD91"))
                    }
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "7AFD91")))
                } else {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? Color(hex: "7AFD91") : .gray)
                }
            }
            .padding(20)
            .background(isSelected ? Color(hex: "7AFD91").opacity(0.1) : Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(hex: "7AFD91") : Color.clear, lineWidth: 2)
            )
            .cornerRadius(16)
        }
        .disabled(isLoading)
    }
}


#Preview {
    SubscriptionView(isPresented: .constant(true), mainViewModel: MainViewModel())
}
