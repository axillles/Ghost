import SwiftUI
import AVFoundation

struct RadarScreen: View {
    @StateObject private var cameraManager = CameraManager()
    @ObservedObject var radarService = RadarService.shared
    @State private var isFlashlightOn = false
    @State private var isRadarActive = true
    
    var body: some View {
        ZStack {
            // Camera Background
            CameraPreviewView(session: cameraManager.session)
                .edgesIgnoringSafeArea(.all)
            
            // Dark overlay
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Radar with overlay gradient
                ZStack {
                    // Radar component
                    RadarView(radarService: radarService)
                        .frame(width: 200, height: 200)
                        .onTapGesture {
                            toggleRadar()
                        }
                    
                    // Sweep gradient animation
                    if isRadarActive {
                        RadarSweepView()
                            .frame(width: 200, height: 200)
                    }
                }
                
                // START/STOP text
                Button(action: {
                    toggleRadar()
                }) {
                    Text(isRadarActive ? "STOP" : "START")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "7AFD91"))
                        .padding(.top, 20)
                }
                
            }
            
            // Flashlight button (bottom right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        isFlashlightOn.toggle()
                        cameraManager.toggleFlashlight(on: isFlashlightOn)
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
        .onAppear {
            cameraManager.checkPermission()
            radarService.startRadar()
        }
        .onDisappear {
            cameraManager.stopSession()
            radarService.stopRadar()
        }
    }
    
    private func toggleRadar() {
        isRadarActive.toggle()
        if isRadarActive {
            radarService.startRadar()
        } else {
            radarService.stopRadar()
        }
    }
}

// Camera Manager
class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    private var videoDevice: AVCaptureDevice?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let configurationSemaphore = DispatchSemaphore(value: 1)
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                }
            }
        default:
            break
        }
    }
    
    func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Захватываем семафор для предотвращения одновременной конфигурации
            self.configurationSemaphore.wait()
            defer { self.configurationSemaphore.signal() }
            
            // Проверяем, не запущена ли уже сессия
            if self.session.isRunning {
                return
            }
            
            self.session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                self.session.commitConfiguration()
                return
            }
            
            self.videoDevice = device
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
                
                self.session.sessionPreset = .high
                self.session.commitConfiguration()
                
                self.session.startRunning()
            } catch {
                self.session.commitConfiguration()
                print("Camera error: \(error)")
            }
        }
    }
    
    func toggleFlashlight(on: Bool) {
        guard let device = videoDevice, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Flashlight error: \(error)")
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Захватываем семафор, чтобы дождаться завершения конфигурации
            self.configurationSemaphore.wait()
            defer { self.configurationSemaphore.signal() }
            
            // Убеждаемся, что сессия запущена перед остановкой
            guard self.session.isRunning else {
                return
            }
            
            self.session.stopRunning()
        }
    }
}

// Camera Preview
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.main.async {
            previewLayer.frame = view.bounds
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            DispatchQueue.main.async {
                layer.frame = uiView.bounds
            }
        }
    }
}

// Radar Sweep Animation
struct RadarSweepView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "7AFD91").opacity(0.8),
                            Color(hex: "7AFD91").opacity(0.4),
                            Color.clear
                        ]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(90)
                    )
                )
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// Radar View
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
                // Outer circle
                Circle()
                    .stroke(Color(hex: "7AFD91"), lineWidth: 3)
                    .frame(width: radius * 2, height: radius * 2)
                    .position(center)
                
                // Inner circles
                ForEach(1..<4, id: \.self) { index in
                    Circle()
                        .stroke(Color(hex: "7AFD91").opacity(0.3), lineWidth: 1.5)
                        .frame(
                            width: radius * 2 * CGFloat(index) / 3,
                            height: radius * 2 * CGFloat(index) / 3
                        )
                        .position(center)
                }
                
                // Cross lines
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
                
                // Degree marks
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
                
                // Degree numbers
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

// Helper extension for hex colors


struct RadarScreen_Previews: PreviewProvider {
    static var previews: some View {
        RadarScreen()
    }
}
