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

struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        controller.view.backgroundColor = .black
        controller.view.contentMode = .scaleAspectFill
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
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
        
        playerItem?.preferredForwardBufferDuration = 5
        playerItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = false
        
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        
        queuePlayer.automaticallyWaitsToMinimizeStalling = false
        
        queuePlayer.appliesMediaSelectionCriteriaAutomatically = true
        
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
