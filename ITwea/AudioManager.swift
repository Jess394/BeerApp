//
//  AudioManager.swift
//  ITwea - Beer Drinking Simulation
//
//  Created by Jess Cadena on 6/19/25.
//

import Foundation
import AVFoundation
import UIKit

/// Manages audio playback for beer simulation sound effects
class AudioManager: ObservableObject {
    // MARK: - Properties
    private var pourPlayer: AVAudioPlayer?
    private var drinkPlayer: AVAudioPlayer?
    private var bubblePlayer: AVAudioPlayer?
    private var resetPlayer: AVAudioPlayer?
    
    @Published var isAudioEnabled = true
    @Published var volume: Float = TeaConfiguration.Audio.defaultVolume
    
    // MARK: - Configuration
    private let audioSession = AVAudioSession.sharedInstance()
    
    init() {
        setupAudioSession()
        createPlaceholderSounds()
    }
    
    deinit {
        stopAllAudio()
    }
    
    // MARK: - Public Methods
    
    /// Setup audio session for the app
    func setupAudioSession() {
        do {
            try audioSession.setCategory(
                TeaConfiguration.Audio.sessionCategory,
                mode: TeaConfiguration.Audio.sessionMode,
                options: TeaConfiguration.Audio.sessionOptions
            )
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    /// Play pouring sound effect
    func playPourSound() {
        guard isAudioEnabled else { return }
        playSound(player: &pourPlayer, volume: volume)
    }
    
    /// Play drinking sound effect
    func playDrinkSound() {
        guard isAudioEnabled else { return }
        playSound(player: &drinkPlayer, volume: volume * TeaConfiguration.Audio.drinkVolumeMultiplier)
    }
    
    /// Play bubble sound effect
    func playBubbleSound() {
        guard isAudioEnabled else { return }
        playSound(player: &bubblePlayer, volume: volume * TeaConfiguration.Audio.bubbleVolumeMultiplier)
    }
    
    /// Play reset/refill sound effect
    func playResetSound() {
        guard isAudioEnabled else { return }
        playSound(player: &resetPlayer, volume: volume)
    }
    
    /// Stop all audio playback
    func stopAllAudio() {
        pourPlayer?.stop()
        drinkPlayer?.stop()
        bubblePlayer?.stop()
        resetPlayer?.stop()
    }
    
    /// Toggle audio on/off
    func toggleAudio() {
        isAudioEnabled.toggle()
        if !isAudioEnabled {
            stopAllAudio()
        }
    }
    
    // MARK: - Private Methods
    
    private func playSound(player: inout AVAudioPlayer?, volume: Float) {
        guard let player = player else { return }
        
        player.volume = volume
        player.currentTime = 0
        player.play()
    }
    
    private func createPlaceholderSounds() {
        // Create placeholder sounds using system sounds
        // In a real app, you would load actual audio files
        
        // Pour sound - using system sound
        createSystemSoundPlayer(&pourPlayer, systemSoundID: 1007) // System sound for liquid
        
        // Drink sound - using system sound
        createSystemSoundPlayer(&drinkPlayer, systemSoundID: 1008) // System sound for gulp
        
        // Bubble sound - using system sound
        createSystemSoundPlayer(&bubblePlayer, systemSoundID: 1009) // System sound for bubble
        
        // Reset sound - using system sound
        createSystemSoundPlayer(&resetPlayer, systemSoundID: 1010) // System sound for reset
    }
    
    private func createSystemSoundPlayer(_ player: inout AVAudioPlayer?, systemSoundID: SystemSoundID) {
        // Create a simple tone as placeholder
        let sampleRate: Double = 44100
        let duration: Double = 0.5
        let frequency: Double = 440.0 // A4 note
        
        let frameCount = Int(sampleRate * duration)
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(frameCount)) else {
            return
        }
        
        audioBuffer.frameLength = AVAudioFrameCount(frameCount)
        
        // Generate simple sine wave
        if let channelData = audioBuffer.floatChannelData?[0] {
            for frame in 0..<frameCount {
                let sample = sin(2.0 * Double.pi * frequency * Double(frame) / sampleRate)
                channelData[frame] = Float(sample * 0.3) // Reduce volume
            }
        }
        
        // Convert buffer to data
        do {
            let audioFile = try AVAudioFile(forWriting: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.wav"), settings: audioFormat.settings)
            try audioFile.write(from: audioBuffer)
            
            let audioData = try Data(contentsOf: audioFile.url)
            player = try AVAudioPlayer(data: audioData)
            player?.prepareToPlay()
        } catch {
            print("Failed to create audio player: \(error)")
        }
    }
}

// MARK: - Audio File Management
extension AudioManager {
    /// Load audio file from bundle
    private func loadAudioFile(named filename: String, withExtension ext: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else {
            print("Could not find audio file: \(filename).\(ext)")
            return nil
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            print("Failed to load audio file: \(error)")
            return nil
        }
    }
}

// MARK: - Audio Instructions
/*
 AUDIO ASSETS INSTRUCTIONS:
 
 To replace placeholder sounds with real audio files:
 
 1. Add audio files to your Xcode project:
    - pour_sound.wav (liquid pouring sound)
    - drink_sound.wav (gulping/drinking sound)
    - bubble_sound.wav (bubbling/fizzing sound)
    - reset_sound.wav (glass refill sound)
 
 2. Replace the createPlaceholderSounds() method with:
 
 private func createPlaceholderSounds() {
     pourPlayer = loadAudioFile(named: "pour_sound", withExtension: "wav")
     drinkPlayer = loadAudioFile(named: "drink_sound", withExtension: "wav")
     bubblePlayer = loadAudioFile(named: "bubble_sound", withExtension: "wav")
     resetPlayer = loadAudioFile(named: "reset_sound", withExtension: "wav")
 }
 
 3. Recommended audio specifications:
    - Format: WAV or MP3
    - Sample Rate: 44.1 kHz
    - Duration: 0.5-2.0 seconds
    - Volume: Normalized to -12dB
 */ 
