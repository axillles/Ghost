//
//  MagnetometerView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI

struct MagnetometerView: View {
    @ObservedObject var magnetometerService = MagnetometerService.shared
    
    var body: some View {
        VStack(spacing: 20) {
            // Индикатор значения
            Text("\(Int(magnetometerService.reading.value))")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            // Анимация свечи
            CandleView(intensity: magnetometerService.reading.candleIntensity)
        }
    }
}

struct CandleView: View {
    let intensity: Double
    
    var body: some View {
        ZStack {
            // Свеча
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.9))
                .frame(width: 40, height: 120)
            
            // Пламя
            VStack {
                Spacer()
                
                ZStack {
                    // Внешнее пламя
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [.yellow.opacity(intensity), .orange.opacity(intensity * 0.7), .clear],
                                center: .center,
                                startRadius: 5,
                                endRadius: 20
                            )
                        )
                        .frame(width: 30, height: 40)
                        .offset(y: -5)
                    
                    // Внутреннее пламя
                    Ellipse()
                        .fill(Color.yellow.opacity(intensity))
                        .frame(width: 15, height: 25)
                        .offset(y: -5)
                }
                .offset(y: intensity * 5)
            }
        }
        .frame(width: 40, height: 120)
    }
}

#Preview {
    MagnetometerView()
        .background(Color.black)
}
