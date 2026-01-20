//
//  SpiritBoxView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI

struct SpiritBoxView: View {
    @StateObject private var audioService = AudioService.shared
    @State private var isActive = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Spirit Box Display
            VStack(spacing: 20) {
                // Title
                Text("SPIRIT BOX")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "7AFD91"))
                    .tracking(3)
                
                // Status indicator
                ZStack {
                    Circle()
                        .fill(isActive ? Color(hex: "7AFD91").opacity(0.2) : Color.clear)
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .stroke(isActive ? Color(hex: "7AFD91") : Color.gray.opacity(0.3), lineWidth: 3)
                        .frame(width: 150, height: 150)
                    
                    if isActive {
                        Image(systemName: "waveform")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: "7AFD91"))
                    } else {
                        Image(systemName: "waveform.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    }
                }
                
                // Status text
                Text(isActive ? "SCANNING" : "STANDBY")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isActive ? Color(hex: "7AFD91") : .gray)
                    .tracking(2)
            }
            
            Spacer()
            
            // Control button
            Button(action: {
                isActive.toggle()
                if isActive {
                    audioService.playSpiritSound()
                } else {
                    audioService.stopSpiritSound()
                }
            }) {
                Text(isActive ? "STOP" : "START")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isActive ? Color.red : Color(hex: "7AFD91"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .padding()
    }
}

#Preview {
    SpiritBoxView()
        .background(Color.black)
}
