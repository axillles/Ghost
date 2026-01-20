//
//  EMFView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI

struct EMFView: View {
    @ObservedObject var magnetometerService = MagnetometerService.shared
    
    var body: some View {
        VStack(spacing: 30) {
            // EMF Meter Display
            VStack(spacing: 15) {
                Text("EMF READER")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "7AFD91"))
                    .tracking(2)
                
                // EMF Value Display
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color(hex: "7AFD91").opacity(0.3), lineWidth: 3)
                        .frame(width: 200, height: 200)
                    
                    // Value
                    Text("\(Int(magnetometerService.reading.value))")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(Color(hex: "7AFD91"))
                }
                
                // Level indicator
                Text("LEVEL \(Int(magnetometerService.reading.value / 10))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    EMFView()
        .background(Color.black)
}
