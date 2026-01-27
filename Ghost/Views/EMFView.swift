//
//  EMFView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI
import AVFoundation

struct EMFScreen: View {
    @ObservedObject private var emfService = EMFService.shared // для плавного перехода между экранами с камерой
    
    @State private var isFlashlightOn = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                // EMFGaugeView по центру
                EMFGaugeView(value: emfService.currentValue)
                    .frame(width: 300, height: 150, alignment: .top)
                    .padding(.bottom, 35)
            }
            
            // Фонарик справа
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        isFlashlightOn.toggle()
                        toggleFlashlight(on: isFlashlightOn)
                    }) {
                        Image(systemName: isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.system(size: 32))
                            .foregroundColor(isFlashlightOn ? Color(hex: "7AFD91") : .white)
                            .padding(20)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 30)
                }
            }
        }
        .padding(.bottom, 20)
        .onAppear {
            DispatchQueue.main.async {
                emfService.startSensor()
            }
        }
        .onDisappear {
            emfService.stopSensor()
        }
    }
    
    private func toggleFlashlight(on: Bool) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Flashlight error: \(error)")
        }
    }
}

struct EMFScreen_Previews: PreviewProvider {
    static var previews: some View {
        EMFScreen()
            .preferredColorScheme(.dark)
    }
}
