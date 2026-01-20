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
            audioPlayer?.volume = 0.5
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    func addSoundFiles(_ files: [String]) {
        soundFiles.append(contentsOf: files)
    }
}
