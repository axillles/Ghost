//
//  LoopingVideoPlayer.swift
//  Ghost
//
//  Created by Артем Гаврилов on 21.01.26.
//

import SwiftUI
import AVFoundation

struct LoopingVideoPlayer: UIViewRepresentable {
    let videoName: String
    let videoExtension: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let player = AVPlayer()
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        
        var url: URL?
        
        url = Bundle.main.url(forResource: videoName, withExtension: videoExtension)
        
        if url == nil {
            url = Bundle.main.url(forResource: videoName, withExtension: videoExtension, subdirectory: "Resources")
        }
        
        guard let videoURL = url else {
            print("Video file not found: \(videoName).\(videoExtension)")
            return view
        }
        
        let playerItem = AVPlayerItem(url: videoURL)
        player.replaceCurrentItem(with: playerItem)
        
        let observer = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
        
        context.coordinator.player = player
        context.coordinator.playerLayer = playerLayer
        context.coordinator.observer = observer
        context.coordinator.playerItem = playerItem
        
        player.play()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerLayer = context.coordinator.playerLayer {
            playerLayer.frame = uiView.bounds
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.player?.pause()
        coordinator.player = nil
        if let observer = coordinator.observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    class Coordinator {
        var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
        var observer: NSObjectProtocol?
        var playerItem: AVPlayerItem?
        
        deinit {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}
