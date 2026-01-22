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
        // Загружаем файлы Radar
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
        
        // Загружаем файлы Spirit
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
        
        // Загружаем EMF файл
        emfURL = findSoundFile(fileName: emfFile, subdirectory: "Sounds/EMF")
        if emfURL != nil {
            print("📦 Loaded EMF sound file")
        } else {
            print("⚠️ Warning: EMF file \(emfFile).mp3 not found")
        }
    }
    
    private func findSoundFile(fileName: String, subdirectory: String) -> URL? {
        // Способ 1: С subdirectory (стандартный способ)
        if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3", subdirectory: subdirectory) {
            return url
        }
        
        // Способ 2: С "Resources/" префиксом
        if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3", subdirectory: "Resources/\(subdirectory)") {
            return url
        }
        
        // Способ 3: Без "Sounds/" префикса
        let dirName = subdirectory.replacingOccurrences(of: "Sounds/", with: "")
        if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3", subdirectory: dirName) {
            return url
        }
        
        // Способ 4: Прямой путь через resourcePath
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
        
        // Способ 5: Без subdirectory
        if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            return url
        }
        
        return nil
    }
    
    func playForMode(_ mode: AudioMode) {
        // Если режим не изменился, ничего не делаем
        guard currentMode != mode else { return }
        
        // Останавливаем текущее воспроизведение
        stop()
        
        currentMode = mode
        
        switch mode {
        case .radar:
            playRadarSound()
        case .emf:
            playEMFSound()
        case .spirit:
            playSpiritSound()
        case .none:
            break
        }
    }
    
    private func playRadarSound() {
        guard !radarFiles.isEmpty, currentMode == .radar else { return }
        
        // Выбираем случайный файл
        let randomFile = radarFiles.randomElement()!
        
        // Используем кэшированный URL или пытаемся найти файл
        if let url = radarURLs[randomFile] {
            playSound(url: url, shouldLoop: false)
        } else {
            // Если URL не найден в кэше, пытаемся найти файл
            if let url = findSoundFile(fileName: randomFile, subdirectory: "Sounds/Radar") {
                radarURLs[randomFile] = url
                playSound(url: url, shouldLoop: false)
            } else {
                print("❌ Error: Radar sound file \(randomFile).mp3 not found")
            }
        }
    }
    
    private func playEMFSound() {
        guard currentMode == .emf else { return }
        
        // Используем кэшированный URL или пытаемся найти файл
        if let url = emfURL {
            playSound(url: url, shouldLoop: true)
        } else {
            // Если URL не найден в кэше, пытаемся найти файл
            if let url = findSoundFile(fileName: emfFile, subdirectory: "Sounds/EMF") {
                emfURL = url
                playSound(url: url, shouldLoop: true)
            } else {
                print("❌ Error: EMF sound file \(emfFile).mp3 not found")
            }
        }
    }
    
    private func playSpiritSound() {
        guard !spiritFiles.isEmpty, currentMode == .spirit else { return }
        
        // Выбираем случайный файл
        let randomFile = spiritFiles.randomElement()!
        
        // Используем кэшированный URL или пытаемся найти файл
        if let url = spiritURLs[randomFile] {
            playSound(url: url, shouldLoop: false)
        } else {
            // Если URL не найден в кэше, пытаемся найти файл
            if let url = findSoundFile(fileName: randomFile, subdirectory: "Sounds/Spirit") {
                spiritURLs[randomFile] = url
                playSound(url: url, shouldLoop: false)
            } else {
                print("❌ Error: Spirit sound file \(randomFile).mp3 not found")
            }
        }
    }
    
    private func playSound(url: URL, shouldLoop: Bool) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.volume = Float(volume)
            audioPlayer?.numberOfLoops = shouldLoop ? -1 : 0
            audioPlayer?.play()
        } catch {
            print("❌ Error playing sound: \(error)")
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentMode = .none
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func resume() {
        audioPlayer?.play()
    }
    
    // Метод для воспроизведения Spirit_6 в зацикленном режиме (для onboarding)
    func playOnboardingMusic() {
        // Останавливаем текущее воспроизведение, если есть
        stop()
        
        // Ищем файл Spirit_6
        let fileName = "Spirit_6"
        if let url = spiritURLs[fileName] ?? findSoundFile(fileName: fileName, subdirectory: "Sounds/Spirit") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = nil // Не нужен делегат для зацикленного звука
                audioPlayer?.volume = Float(volume)
                audioPlayer?.numberOfLoops = -1 // Зацикливание
                audioPlayer?.play()
                print("✅ Playing onboarding music: \(fileName).mp3")
            } catch {
                print("❌ Error playing onboarding music: \(error)")
            }
        } else {
            print("❌ Error: Onboarding music file \(fileName).mp3 not found")
        }
    }
    
    // Метод для остановки onboarding музыки
    func stopOnboardingMusic() {
        stop()
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Если звук закончился и это режим с случайными звуками, запускаем следующий
        // Добавляем небольшую задержку для более естественного воспроизведения
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if self.currentMode == .radar {
                self.playRadarSound()
            } else if self.currentMode == .spirit {
                self.playSpiritSound()
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio decode error: \(error?.localizedDescription ?? "Unknown error")")
        // При ошибке также пытаемся запустить следующий звук
        if currentMode == .radar {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.playRadarSound()
            }
        } else if currentMode == .spirit {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.playSpiritSound()
            }
        }
    }
}
