//
//  AudioManager.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import Foundation
import AVFoundation

enum AudioMode {
    case radar
    case emf
    case spirit
    case none
}

final class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var currentMode: AudioMode = .none
    private var radarFiles: [String] = []
    private var spiritFiles: [String] = []
    private var emfFile: String = "EMF"
    
    // Кэш для URL файлов
    private var radarURLs: [String: URL] = [:]
    private var spiritURLs: [String: URL] = [:]
    private var emfURL: URL?
    
    var volume: Double = 0.5 {
        didSet {
            audioPlayer?.volume = Float(volume)
        }
    }
    
    private override init() {
        super.init()
        setupAudioSession()
        loadSoundFiles()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    private func loadSoundFiles() {
        radarFiles = ["RADAR_1", "RADAR_2", "RADAR_3", "RADAR_4", "RADAR_5"]
        var loadedRadarCount = 0
        for fileName in radarFiles {
            if let url = findSoundFile(fileName: fileName, subdirectory: "Sounds/Radar") {
                radarURLs[fileName] = url
                loadedRadarCount += 1
            } else {
                print("⚠️ Warning: Radar file \(fileName).mp3 not found")
            }
        }
        print("📦 Loaded \(loadedRadarCount)/\(radarFiles.count) Radar sound files")
        
        spiritFiles = ["Spirit_1", "Spirit_2", "Spirit_3", "Spirit_4", "Spirit_5", "Spirit_6", "Spirit_8", "Spirit_9"]
        var loadedSpiritCount = 0
        for fileName in spiritFiles {
            if let url = findSoundFile(fileName: fileName, subdirectory: "Sounds/Spirit") {
                spiritURLs[fileName] = url
                loadedSpiritCount += 1
            } else {
                print("⚠️ Warning: Spirit file \(fileName).mp3 not found")
            }
        }
        print("📦 Loaded \(loadedSpiritCount)/\(spiritFiles.count) Spirit sound files")
        
        emfURL = findSoundFile(fileName: emfFile, subdirectory: "Sounds/EMF")
        if emfURL != nil {
            print("📦 Loaded EMF sound file")
        } else {
            print("⚠️ Warning: EMF file \(emfFile).mp3 not found")
        }
    }
    
    private func findSoundFile(fileName: String, subdirectory: String) -> URL? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3", subdirectory: subdirectory) {
            return url
        }
        
        if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3", subdirectory: "Resources/\(subdirectory)") {
            return url
        }
        
        let dirName = subdirectory.replacingOccurrences(of: "Sounds/", with: "")
        if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3", subdirectory: dirName) {
            return url
        }
        
        if let resourcePath = Bundle.main.resourcePath {
            let possiblePaths = [
                "\(resourcePath)/\(subdirectory)/\(fileName).mp3",
                "\(resourcePath)/Resources/\(subdirectory)/\(fileName).mp3",
                "\(resourcePath)/\(fileName).mp3"
            ]
            
            for path in possiblePaths {
                if FileManager.default.fileExists(atPath: path) {
                    return URL(fileURLWithPath: path)
                }
            }
        }
        
        if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            return url
        }
        
        return nil
    }
    
    func playForMode(_ mode: AudioMode) {
        stopImmediately()
        
        guard currentMode != mode else {
            print("ℹ️ Mode already set to \(mode), stopped current playback")
            currentMode = mode
            return
        }
        
        print("🔄 Switching from \(currentMode) to \(mode)")
        
        currentMode = mode
        
        switch mode {
        case .radar:
            playRandomRadarSound()
        case .emf:
            playEMFSound()
        case .spirit:
            playRandomSpiritSound()
        case .none:
            print("🔇 Mode set to none - no sound")
        }
    }
    
    /// МОМЕНТАЛЬНАЯ остановка всех звуков
    private func stopImmediately() {
        if let player = audioPlayer {
            player.stop()
            player.delegate = nil
            print("⏹️ Audio stopped immediately")
        }
        audioPlayer = nil
    }
    
    /// Воспроизведение случайного звука Radar
    private func playRandomRadarSound() {
        guard !radarFiles.isEmpty else {
            print("❌ No radar files available")
            return
        }
        
        guard currentMode == .radar else {
            print("⚠️ Mode changed, cancelling radar playback")
            return
        }
        
        let randomFile = radarFiles.randomElement()!
        
        if let url = radarURLs[randomFile] {
            playSound(url: url, shouldLoop: false)
        } else {
            print("❌ Radar sound file \(randomFile).mp3 not found")
        }
    }
    
    /// Воспроизведение EMF звука (зацикленный)
    private func playEMFSound() {
        guard currentMode == .emf else {
            print("⚠️ Mode changed, cancelling EMF playback")
            return
        }
        
        if let url = emfURL {
            playSound(url: url, shouldLoop: true)
        } else {
            print("❌ EMF sound file not found")
        }
    }
    
    /// Воспроизведение случайного звука Spirit
    private func playRandomSpiritSound() {
        guard !spiritFiles.isEmpty else {
            print("❌ No spirit files available")
            return
        }
        
        guard currentMode == .spirit else {
            print("⚠️ Mode changed, cancelling spirit playback")
            return
        }
        
        let randomFile = spiritFiles.randomElement()!
        
        if let url = spiritURLs[randomFile] {
            playSound(url: url, shouldLoop: false)
        } else {
            print("❌ Spirit sound file \(randomFile).mp3 not found")
        }
    }
    
    private func playSound(url: URL, shouldLoop: Bool) {
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            
            guard currentMode != .none else {
                print("⚠️ Mode is none, not playing sound")
                return
            }
            
            audioPlayer = newPlayer
            audioPlayer?.delegate = self
            audioPlayer?.volume = Float(volume)
            audioPlayer?.numberOfLoops = shouldLoop ? -1 : 0
            audioPlayer?.prepareToPlay()
            
            let didStart = audioPlayer?.play() ?? false
            
            if didStart {
                print("▶️ Playing: \(url.lastPathComponent) | Loop: \(shouldLoop) | Mode: \(currentMode)")
            } else {
                print("❌ Failed to start playback")
            }
            
        } catch {
            print("❌ Error creating audio player: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        print("🛑 Stop called")
        stopImmediately()
        currentMode = .none
    }
    
    func pause() {
        audioPlayer?.pause()
        print("⏸️ Audio paused")
    }
    
    func resume() {
        audioPlayer?.play()
        print("▶️ Audio resumed")
    }
    
    // MARK: - Onboarding Music
    
    func playOnboardingMusic() {
        stop()
        
        let fileName = "Spirit_6"
        if let url = spiritURLs[fileName] ?? findSoundFile(fileName: fileName, subdirectory: "Sounds/Spirit") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = nil
                audioPlayer?.volume = Float(volume)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                print("✅ Playing onboarding music: \(fileName).mp3")
            } catch {
                print("❌ Error playing onboarding music: \(error)")
            }
        } else {
            print("❌ Onboarding music file not found")
        }
    }
    
    func stopOnboardingMusic() {
        stop()
    }
    
    // MARK: - Preload (для оптимизации)
    
    func preloadAllSounds() {
        print("🔄 Preloading all sounds...")
        
        if let radarURL = radarURLs.values.first {
            _ = try? AVAudioPlayer(contentsOf: radarURL)
        }
        
        if let spiritURL = spiritURLs.values.first {
            _ = try? AVAudioPlayer(contentsOf: spiritURL)
        }
        
        if let emfURL = emfURL {
            _ = try? AVAudioPlayer(contentsOf: emfURL)
        }
        
        print("✅ All sounds preloaded")
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard player === audioPlayer else {
            print("⚠️ Finished player is not current player")
            return
        }
        
        print("✅ Sound finished playing successfully: \(flag)")
        
        // Запускаем следующий РАНДОМНЫЙ звук после короткой паузы
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            switch self.currentMode {
            case .radar:
                print("🔄 Playing next random radar sound")
                self.playRandomRadarSound()
            case .spirit:
                print("🔄 Playing next random spirit sound")
                self.playRandomSpiritSound()
            case .emf:
                break
            case .none:
                print("ℹ️ Mode is none, not playing next sound")
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("❌ Audio decode error: \(error?.localizedDescription ?? "Unknown")")
        
        guard player === audioPlayer else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            switch self.currentMode {
            case .radar:
                print("🔄 Retrying radar after error")
                self.playRandomRadarSound()
            case .spirit:
                print("🔄 Retrying spirit after error")
                self.playRandomSpiritSound()
            default:
                break
            }
        }
    }
}
