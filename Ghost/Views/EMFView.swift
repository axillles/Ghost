//
//  EMFView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI
import AVFoundation

struct EMFScreen: View {
    // Используем shared экземпляр EMFService
    @ObservedObject private var emfService = EMFService.shared
    
    @State private var isFlashlightOn = false
    
    var body: some View {
        ZStack {
            // Камера уже отображается в MainView как фон, здесь только контент
            
            VStack {
                Spacer()
                
                // 2. Основной датчик
                // Обрезаем нижнюю половину, чтобы получился полукруг как на макете

                
                // 3. Нижняя панель с кнопкой фонарика
                HStack(alignment: .bottom) {
                    Spacer()
                    EMFGaugeView(value: emfService.currentValue)
                        .frame(width: 300, height: 150, alignment: .top)
                         // Обрезаем все что ниже центра
                        .padding(.bottom, 10)
                    Spacer()
                    
                    // Кнопка фонарика (Справа внизу)
                    Button(action: {
                        isFlashlightOn.toggle()
                        toggleFlashlight(on: isFlashlightOn)
                    }) {
                        Image(systemName: isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.system(size: 24))
                            .foregroundColor(isFlashlightOn ? .black : .white)
                            .padding(16)
                            .background(isFlashlightOn ? Color.white : Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(isFlashlightOn ? 0 : 0.5), lineWidth: 1)
                            )
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            // Запускаем асинхронно, чтобы не блокировать UI
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

// Для предпросмотра в Xcode
struct EMFScreen_Previews: PreviewProvider {
    static var previews: some View {
        EMFScreen()
            .preferredColorScheme(.dark)
    }
}
