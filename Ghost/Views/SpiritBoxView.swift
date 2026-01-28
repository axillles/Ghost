import SwiftUI
import AVKit
import AVFoundation

struct SpiritBoxView: View {
    @StateObject private var videoPlayerManager = VideoPlayerManager()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
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

struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.backgroundColor = .black
        
        // Создаем AVPlayerLayer для лучшего контроля качества
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        
        // Критически важные настройки для четкости
        playerLayer.magnificationFilter = .nearest // Убирает размытие при увеличении
        playerLayer.minificationFilter = .nearest // Убирает размытие при уменьшении
        playerLayer.shouldRasterize = false // Отключаем растеризацию
        playerLayer.isOpaque = true // Улучшает производительность
        
        view.layer.addSublayer(playerLayer)
        context.coordinator.playerLayer = playerLayer
        
        return view
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) {
        // Обновляем frame при изменении размера
        DispatchQueue.main.async {
            context.coordinator.playerLayer?.frame = uiView.bounds
        }
    }
    
    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}

// Кастомный UIView для правильной работы с AVPlayerLayer
class PlayerView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        // Обновляем frame слоя при изменении размера view
        if let playerLayer = layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = bounds
        }
    }
}

class VideoPlayerManager: ObservableObject {
    @Published var player: AVPlayer?
    private var playerLooper: AVPlayerLooper?
    private var playerItem: AVPlayerItem?
    
    func setupPlayer() {
        guard player == nil else {
            player?.play()
            return
        }
        
        guard let videoURL = Bundle.main.url(forResource: "candle", withExtension: "mp4") else {
            print("❌ Видео candle.mp4 не найдено в Bundle")
            return
        }
        
        let asset = AVAsset(url: videoURL)
        playerItem = AVPlayerItem(asset: asset)
        
        // Настройки для лучшего качества воспроизведения
        playerItem?.preferredForwardBufferDuration = 5
        playerItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = false
        
        // Включаем автоматическую обработку качества
        if #available(iOS 13.0, *) {
            playerItem?.automaticallyHandlesInterstitialEvents = true
        }
        
        // Настройки для лучшего качества видео
        playerItem?.videoComposition = nil // Используем оригинальное качество
        
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        
        queuePlayer.automaticallyWaitsToMinimizeStalling = false
        
        queuePlayer.appliesMediaSelectionCriteriaAutomatically = true
        
        // Настройки для лучшего качества
        if #available(iOS 16.0, *) {
            queuePlayer.preventsDisplaySleepDuringVideoPlayback = true
        }
        
        // Используем высокое качество рендеринга
        queuePlayer.allowsExternalPlayback = false // Отключаем внешнее воспроизведение для лучшего контроля качества
        
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem!)
    
        queuePlayer.isMuted = true
        
        player = queuePlayer
        
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
        player?.pause()
        
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
