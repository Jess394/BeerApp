//
//  ContentView.swift
//  ITwea - Twisted Tea Simulation
//
//  Created by Jess Cadena on 6/19/25.
//

import SwiftUI
import SpriteKit

/// Main view for Twisted Tea simulation with modern UI and full-screen experience
struct ContentView: View {
    
    // MARK: - State Properties
    @State private var selectedTeaType: TeaConfiguration.TeaType = .original
    @State private var isPouring = false
    @State private var isRefilling = false
    @State private var showInstructions = true
    
    // MARK: - Scene Properties
    private var teaScene: TeaScene {
        let scene = TeaScene()
        
        // Calculate available space for the scene - no padding except bottom
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let availableHeight = screenHeight - TeaConfiguration.UI.bottomBarHeight
        
        // Set scene size to use full width and available height
        scene.size = CGSize(width: screenWidth, height: availableHeight)
        scene.scaleMode = .aspectFit
        
        print("ContentView: Scene size set to \(scene.size)")
        return scene
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: TeaConfiguration.UI.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main tea simulation area
                teaSimulationArea
                
                // Bottom control bar
                bottomControlBar
            }
            
            // Instructions overlay
            if showInstructions {
                instructionsOverlay
            }
        }
        .onAppear {
            setupNotificationObservers()
        }
        .onDisappear {
            removeNotificationObservers()
        }
    }
    
    // MARK: - Tea Simulation Area
    private var teaSimulationArea: some View {
        ZStack {
            // Glass container with blur effect - no padding except bottom
            RoundedRectangle(cornerRadius: TeaConfiguration.UI.glassContainerCornerRadius)
                .fill(.clear)
                .background(TeaConfiguration.UI.glassBackgroundMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: TeaConfiguration.UI.glassContainerCornerRadius)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .padding(.bottom, 20) // Only bottom padding
            
            // SpriteKit scene - no padding except bottom
            SpriteView(scene: teaScene)
                .clipShape(RoundedRectangle(cornerRadius: TeaConfiguration.UI.sceneCornerRadius))
                .padding(.bottom, 25) // Only bottom padding
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Bottom Control Bar
    private var bottomControlBar: some View {
        VStack(spacing: 0) {
            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 1)
            
            // Control bar content
            HStack(spacing: 20) {
                // Tea type selector
                teaTypeSelector
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 15) {
                    pourButton
                    refillButton
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 20)
            .background(TeaConfiguration.UI.bottomBarBackground)
        }
        .frame(height: TeaConfiguration.UI.bottomBarHeight)
    }
    
    // MARK: - Tea Type Selector
    private var teaTypeSelector: some View {
        Menu {
            ForEach(TeaConfiguration.TeaType.allCases, id: \.self) { teaType in
                Button(action: {
                    selectedTeaType = teaType
                    changeTeaType(teaType)
                }) {
                    HStack {
                        Text(teaType.rawValue)
                        if selectedTeaType == teaType {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(.white)
                Text(selectedTeaType.rawValue)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                Image(systemName: "chevron.down")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(TeaConfiguration.UI.buttonCornerRadius)
        }
    }
    
    // MARK: - Action Buttons
    private var pourButton: some View {
        Button(action: {
            pourTea()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "drop.fill")
                    .foregroundColor(.white)
                Text("Pour")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(TeaConfiguration.UI.buttonCornerRadius)
            .scaleEffect(isPouring ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPouring)
        }
        .disabled(isPouring)
    }
    
    private var refillButton: some View {
        Button(action: {
            refillTea()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.white)
                Text("Refill")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color.green.opacity(0.8), Color.green.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(TeaConfiguration.UI.buttonCornerRadius)
            .scaleEffect(isRefilling ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isRefilling)
        }
        .disabled(isRefilling)
    }
    
    // MARK: - Instructions Overlay
    private var instructionsOverlay: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                Text("Tilt Your Phone")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Hold your phone like a glass and tilt it to drink the tea!")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 20)
            .background(TeaConfiguration.UI.instructionsBackgroundMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 40)
            
            Button("Got it!") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showInstructions = false
                }
            }
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .medium))
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.2))
            .cornerRadius(TeaConfiguration.UI.buttonCornerRadius)
            
            Spacer()
        }
        .transition(.opacity)
    }
    
    // MARK: - Actions
    private func pourTea() {
        isPouring = true
        
        // Send notification to scene
        NotificationCenter.default.post(name: .pourTea, object: nil)
        
        // Reset button state after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isPouring = false
        }
    }
    
    private func refillTea() {
        isRefilling = true
        
        // Send notification to scene
        NotificationCenter.default.post(name: .refillTea, object: nil)
        
        // Reset button state after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isRefilling = false
        }
    }
    
    private func changeTeaType(_ teaType: TeaConfiguration.TeaType) {
        // Send notification to scene
        NotificationCenter.default.post(name: .changeTeaType, object: teaType)
    }
    
    // MARK: - Notification Setup
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .pourTea,
            object: nil,
            queue: .main
        ) { _ in
            // Handle pour notification if needed
        }
        
        NotificationCenter.default.addObserver(
            forName: .refillTea,
            object: nil,
            queue: .main
        ) { _ in
            // Handle refill notification if needed
        }
        
        NotificationCenter.default.addObserver(
            forName: .changeTeaType,
            object: nil,
            queue: .main
        ) { notification in
            if let teaType = notification.object as? TeaConfiguration.TeaType {
                selectedTeaType = teaType
            }
        }
    }
    
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let pourTea = Notification.Name("pourTea")
    static let refillTea = Notification.Name("refillTea")
    static let changeTeaType = Notification.Name("changeTeaType")
}

// MARK: - Preview
#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
