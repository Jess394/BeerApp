//
//  ContentView.swift
//  ITwea - Beer Drinking Simulation
//
//  Created by Jess Cadena on 6/19/25.
//

import SwiftUI
import SpriteKit
import CoreMotion

struct BeerDrinkingView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var motionManager: MotionManager
    @EnvironmentObject var audioManager: AudioManager
    
    // MARK: - State
    @State private var beerLevel: Double = 1.0 // 0.0 = empty, 1.0 = full
    @State private var isPouring = false
    @State private var showInstructions = true
    @State private var selectedBeerType: BeerConfiguration.BeerType = .lager
    @State private var showBeerTypePicker = false
    
    // MARK: - Computed Properties
    private var scene: SKScene {
        let scene = BeerScene()
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .clear
        return scene
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: BeerConfiguration.UI.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Title
                Text("🍺 Beer Simulator")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                // Beer type selector
                HStack {
                    Text("Beer Type:")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Button(selectedBeerType.rawValue) {
                        showBeerTypePicker = true
                    }
                    .foregroundColor(.yellow)
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .cornerRadius(BeerConfiguration.UI.buttonCornerRadius)
                }
                
                // Beer glass with SpriteKit scene
                ZStack {
                    // Glass container
                    RoundedRectangle(cornerRadius: BeerConfiguration.UI.glassContainerCornerRadius)
                        .fill(.clear)
                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        .frame(width: 200, height: 300)
                        .background(
                            RoundedRectangle(cornerRadius: BeerConfiguration.UI.glassContainerCornerRadius)
                                .fill(.clear)
                                .background(BeerConfiguration.UI.glassBackgroundMaterial)
                        )
                    
                    // SpriteKit scene for beer simulation
                    SpriteView(scene: scene)
                        .frame(width: 180, height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: BeerConfiguration.UI.sceneCornerRadius))
                }
                .frame(width: 220, height: 320)
                
                // Controls
                VStack(spacing: 15) {
                    // Beer level slider
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Beer Level: \(Int(beerLevel * 100))%")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Slider(value: $beerLevel, in: 0.0...1.0)
                            .accentColor(.yellow)
                            .onChange(of: beerLevel) { newValue in
                                // Update beer level in SpriteKit scene
                                NotificationCenter.default.post(
                                    name: .updateBeerLevel,
                                    object: newValue
                                )
                            }
                    }
                    .padding(.horizontal)
                    
                    // Pour button
                    Button(action: {
                        isPouring.toggle()
                        if isPouring {
                            audioManager.playPourSound()
                            beerLevel = min(beerLevel + 0.2, 1.0)
                        }
                    }) {
                        HStack {
                            Image(systemName: isPouring ? "stop.fill" : "drop.fill")
                            Text(isPouring ? "Stop Pouring" : "Pour Beer")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(isPouring ? Color.red : Color.blue)
                        .cornerRadius(BeerConfiguration.UI.buttonCornerRadius)
                    }
                    
                    // Reset button
                    Button(action: {
                        beerLevel = 1.0
                        audioManager.playResetSound()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Refill Glass")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(BeerConfiguration.UI.buttonCornerRadius)
                    }
                    
                    // Audio toggle
                    Button(action: {
                        audioManager.toggleAudio()
                    }) {
                        HStack {
                            Image(systemName: audioManager.isAudioEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            Text(audioManager.isAudioEnabled ? "Audio On" : "Audio Off")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(audioManager.isAudioEnabled ? Color.blue : Color.gray)
                        .cornerRadius(BeerConfiguration.UI.buttonCornerRadius)
                    }
                }
                
                Spacer()
            }
            
            // Instructions overlay
            if showInstructions {
                InstructionsOverlay(isShowing: $showInstructions)
            }
        }
        .onReceive(motionManager.$deviceMotion) { motion in
            guard let motion = motion else { return }
            
            // Send motion data to SpriteKit scene
            NotificationCenter.default.post(
                name: .updateDeviceMotion,
                object: motion
            )
        }
        .onChange(of: selectedBeerType) { newBeerType in
            // Update beer type in SpriteKit scene
            NotificationCenter.default.post(
                name: .updateBeerType,
                object: newBeerType
            )
        }
        .sheet(isPresented: $showBeerTypePicker) {
            BeerTypePickerView(selectedBeerType: $selectedBeerType)
        }
    }
}

// MARK: - Beer Type Picker View
struct BeerTypePickerView: View {
    @Binding var selectedBeerType: BeerConfiguration.BeerType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(BeerConfiguration.BeerType.allCases, id: \.self) { beerType in
                Button(action: {
                    selectedBeerType = beerType
                    dismiss()
                }) {
                    HStack {
                        Circle()
                            .fill(Color(beerType.color))
                            .frame(width: 20, height: 20)
                        
                        Text(beerType.rawValue)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedBeerType == beerType {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Beer Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Instructions Overlay
struct InstructionsOverlay: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("🍺 How to Use")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 15) {
                    InstructionRow(icon: "iphone", text: "Tilt your device to see the beer slosh")
                    InstructionRow(icon: "drop.fill", text: "Use the slider to adjust beer level")
                    InstructionRow(icon: "speaker.wave.2", text: "Pour button adds beer with sound effects")
                    InstructionRow(icon: "arrow.clockwise", text: "Refill button resets to full glass")
                    InstructionRow(icon: "paintbrush", text: "Select different beer types for variety")
                }
                .padding()
                .background(BeerConfiguration.UI.instructionsBackgroundMaterial)
                .cornerRadius(15)
                
                Button("Got it!") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowing = false
                    }
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(BeerConfiguration.UI.buttonCornerRadius)
            }
            .padding()
        }
        .transition(.opacity)
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.yellow)
                .frame(width: 20)
            
            Text(text)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

#Preview {
    BeerDrinkingView()
        .environmentObject(MotionManager())
        .environmentObject(AudioManager())
}
