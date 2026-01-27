import SwiftUI
import AVFoundation

struct RadarScreen: View {
    @ObservedObject var radarService = RadarService.shared
    @ObservedObject private var audioManager = AudioManager.shared
    private let storage = StorageService.shared
    @State private var isFlashlightOn = false
    
    var body: some View {
        ZStack {
            
            VStack {
                Spacer()
                
                ZStack {
                    RadarView(radarService: radarService)
                        .frame(width: 190, height: 190)
                        .onTapGesture {
                            toggleRadar()
                        }
                    
                    if radarService.isActive {
                        RadarSweepView()
                            .frame(width: 200, height: 200)
                    }
                }
                
                Button(action: {
                    toggleRadar()
                }) {
                    Text(radarService.isActive ? "STOP" : "START")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(Color(hex: "7AFD91"))
                        .padding(.top, 40)
                }
                
            }
            
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
        .onDisappear {
            radarService.stopRadar()
            let settings = storage.loadSettings()
            if settings.soundEnabled {
                audioManager.stop()
            }
        }
    }
    
    private func toggleRadar() {
        let settings = storage.loadSettings()
        
        if radarService.isActive {
            radarService.stopRadar()
            if settings.soundEnabled {
                audioManager.stop()
            }
        } else {
            radarService.startRadar()
            if settings.soundEnabled {
                audioManager.playForMode(.radar)
            }
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

struct RadarSweepView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let sweepAngle: Double = 90 // Ширина луча в градусах
            
            ZStack {
                Path { path in
                    path.move(to: center)
                    path.addLine(to: CGPoint(x: center.x, y: 0))
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(-90 + sweepAngle),
                        clockwise: false
                    )
                    path.addLine(to: center)
                }
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "7AFD91").opacity(0.1),
                            Color(hex: "7AFD91").opacity(0.4),
                            Color(hex: "7AFD91").opacity(0.7),
                            Color(hex: "7AFD91").opacity(0.9)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
                .rotationEffect(.degrees(rotation))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}
struct RadarView: View {
    @ObservedObject var radarService: RadarService
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RadarGrid()
                
                ForEach(radarService.dots) { dot in
                    RadarDotView(dot: dot, size: geometry.size)
                }
                
                CenterDot(size: geometry.size)
            }
        }
    }
}

struct CenterDot: View {
    let size: CGSize
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 8, height: 8)
            .position(x: size.width / 2, y: size.height / 2)
    }
}

struct RadarDotView: View {
    let dot: GhostDot
    let size: CGSize
    
    var body: some View {
        Circle()
            .fill(Color.red.opacity(dot.intensity))
            .frame(width: 12, height: 12)
            .position(
                x: dot.position.x * size.width,
                y: dot.position.y * size.height
            )
            .blur(radius: 2)
    }
}

struct RadarGrid: View {
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2
            
            ZStack {
                Circle()
                    .stroke(Color(hex: "7AFD91"), lineWidth: 3)
                    .frame(width: radius * 2, height: radius * 2)
                    .position(center)
                
                ForEach(1..<4, id: \.self) { index in
                    Circle()
                        .stroke(Color(hex: "7AFD91").opacity(0.3), lineWidth: 1.5)
                        .frame(
                            width: radius * 2 * CGFloat(index) / 3,
                            height: radius * 2 * CGFloat(index) / 3
                        )
                        .position(center)
                }
                
                Path { path in
                    path.move(to: CGPoint(x: center.x, y: center.y - radius))
                    path.addLine(to: CGPoint(x: center.x, y: center.y + radius))
                }
                .stroke(Color(hex: "7AFD91").opacity(0.3), lineWidth: 1.5)
                
                Path { path in
                    path.move(to: CGPoint(x: center.x - radius, y: center.y))
                    path.addLine(to: CGPoint(x: center.x + radius, y: center.y))
                }
                .stroke(Color(hex: "7AFD91").opacity(0.3), lineWidth: 1.5)
                
                ForEach(0..<36, id: \.self) { index in
                    let angle = Double(index) * 10 * .pi / 180
                    let isMainMark = index % 3 == 0
                    let length: CGFloat = isMainMark ? 15 : 8
                    
                    Path { path in
                        let startPoint = CGPoint(
                            x: center.x + cos(angle) * (radius - length),
                            y: center.y + sin(angle) * (radius - length)
                        )
                        let endPoint = CGPoint(
                            x: center.x + cos(angle) * radius,
                            y: center.y + sin(angle) * radius
                        )
                        path.move(to: startPoint)
                        path.addLine(to: endPoint)
                    }
                    .stroke(Color(hex: "7AFD91"), lineWidth: isMainMark ? 2 : 1)
                }
                
                ForEach([0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330], id: \.self) { degree in
                    let angle = Double(degree) * .pi / 180
                    Text("\(degree)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "7AFD91"))
                        .position(
                            x: center.x + cos(angle - .pi / 2) * (radius + 25),
                            y: center.y + sin(angle - .pi / 2) * (radius + 25)
                        )
                }
            }
        }
    }
}



struct RadarScreen_Previews: PreviewProvider {
    static var previews: some View {
        RadarScreen()
            .preferredColorScheme(.dark)
    }
}
