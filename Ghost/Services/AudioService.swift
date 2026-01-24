//
//  AudioService.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import Foundation
import AVFoundation

final class AudioService: ObservableObject {
    static let shared = AudioService()
    
    private var audioPlayer: AVAudioPlayer?
    private var soundFiles: [String] = []
    var volume: Double = 0.5 {
        didSet {
            audioPlayer?.volume = Float(volume)
        }
    }
    
    private init() {
        loadSoundFiles()
    }
    
    private func loadSoundFiles() {
        // Загружаем все звуковые файлы из Bundle
        if let resourcePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            do {
                let files = try fileManager.contentsOfDirectory(atPath: resourcePath)
                soundFiles = files.filter { 
                    $0.hasSuffix(".mp3") || $0.hasSuffix(".wav") || $0.hasSuffix(".m4a") || $0.hasSuffix(".aac")
                }
            } catch {
                print("Error loading sound files: \(error)")
            }
        }
    }
    
    func playRandomSound() {
        guard !soundFiles.isEmpty else { return }
        
        let randomFile = soundFiles.randomElement()!
        let fileName = (randomFile as NSString).deletingPathExtension
        
        var fileExtension: String?
        if randomFile.hasSuffix(".mp3") {
            fileExtension = "mp3"
        } else if randomFile.hasSuffix(".wav") {
            fileExtension = "wav"
        } else if randomFile.hasSuffix(".m4a") {
            fileExtension = "m4a"
        } else if randomFile.hasSuffix(".aac") {
            fileExtension = "aac"
        }
        
        guard let ext = fileExtension,
              let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = Float(volume)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    func stopAllSounds() {
        audioPlayer?.stop()
        audioPlayer = nil // Полностью очищаем плеер
    }
    
    func addSoundFiles(_ files: [String]) {
        soundFiles.append(contentsOf: files)
    }
    
    func playSpiritSound() {
        let spiritFiles = ["Spirit_1", "Spirit_2", "Spirit_3", "Spirit_4", "Spirit_5", "Spirit_6", "Spirit_8", "Spirit_9"]
        guard let randomFile = spiritFiles.randomElement(),
              let url = Bundle.main.url(forResource: randomFile, withExtension: "mp3", subdirectory: "Sounds/Spirit") else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = Float(volume)
            audioPlayer?.play()
        } catch {
            print("Error playing spirit sound: \(error)")
        }
    }
    
    func stopSpiritSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
