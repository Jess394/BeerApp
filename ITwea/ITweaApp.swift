//
//  ITweaApp.swift
//  ITwea - Beer Drinking Simulation
//
//  Created by Jess Cadena on 6/19/25.
//

import SwiftUI
import CoreMotion

@main
struct ITweaApp: App {
    // MARK: - Properties
    @StateObject private var motionManager = MotionManager()
    @StateObject private var audioManager = AudioManager()
    
    var body: some Scene {
        WindowGroup {
            BeerDrinkingView()
                .environmentObject(motionManager)
                .environmentObject(audioManager)
                .onAppear {
                    // Request motion permissions and start monitoring
                    motionManager.requestMotionPermissions()
                    audioManager.setupAudioSession()
                }
        }
    }
}
