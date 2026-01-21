import SwiftUI
import AVKit
import AVFoundation

struct SpiritBoxView: View {
    @StateObject private var videoPlayerManager = VideoPlayerManager()
    
    var body: some View {
        ZStack {
            if let player = videoPlayerManager.player {
                VideoPlayerView(player: player)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            videoPlayerManager.setupPlayer()
        }
        .onDisappear {
            videoPlayerManager.cleanupPlayer()
        }
    }
}

// Отдельная View для AVPlayer
struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

// Manager для управления памятью и воспроизведением
class VideoPlayerManager: ObservableObject {
    @Published var player: AVPlayer?
    private var playerLooper: AVPlayerLooper?
    private var playerItem: AVPlayerItem?
    
    func setupPlayer() {
        // Проверяем есть ли уже плеер
        guard player == nil else {
            player?.play()
            return
        }
        
        // Получаем путь к видео из Bundle
        guard let videoURL = Bundle.main.url(forResource: "candle", withExtension: "mp4") else {
            print("❌ Видео candle.mp4 не найдено в Bundle")
            return
        }
        
        // Создаем AVPlayerItem с оптимизацией памяти
        let asset = AVAsset(url: videoURL)
        playerItem = AVPlayerItem(asset: asset)
        
        // Создаем AVQueuePlayer для зацикливания
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        
        // Настройка оптимизации памяти
        queuePlayer.automaticallyWaitsToMinimizeStalling = false
        
        // Зацикливание видео
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem!)
        
        // Отключаем звук если нужно
        queuePlayer.isMuted = true
        
        player = queuePlayer
        
        // Устанавливаем рандомную начальную позицию (0-180 секунд для 3-минутного видео)
        let randomSeconds = Double.random(in: 0...180)
        let randomTime = CMTime(seconds: randomSeconds, preferredTimescale: 600)
        
        queuePlayer.seek(to: randomTime) { finished in
            if finished {
                queuePlayer.play()
                print("✅ Видео запущено с \(Int(randomSeconds)) секунды")
            }
        }
    }
    
    func cleanupPlayer() {
        // Останавливаем воспроизведение
        player?.pause()
        
        // Очищаем все ресурсы
        playerLooper = nil
        playerItem = nil
        player = nil
        
        print("🧹 Память очищена")
    }
    
    deinit {
        cleanupPlayer()
        print("♻️ VideoPlayerManager освобожден из памяти")
    }
}

struct CandleVideoScreen_Previews: PreviewProvider {
    static var previews: some View {
        SpiritBoxView()
    }
}
