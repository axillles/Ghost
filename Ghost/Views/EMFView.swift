//
//  EMFView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI
import AVFoundation

struct EMFScreen: View {
    // Используем менеджер камеры из предыдущего задания
    @StateObject private var cameraManager = CameraManager()
    // Наш новый сервис логики EMF
    @StateObject private var emfService = EMFService()
    
    @State private var isFlashlightOn = false
    
    var body: some View {
        ZStack {
            // 1. Фоновый слой - Камера
            CameraPreviewView(session: cameraManager.session)
                .edgesIgnoringSafeArea(.all)
            
            // Темная подложка для контраста
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
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
                        cameraManager.toggleFlashlight(on: isFlashlightOn)
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
            cameraManager.checkPermission()
            emfService.startSensor()
        }
        .onDisappear {
            cameraManager.stopSession()
            emfService.stopSensor()
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
