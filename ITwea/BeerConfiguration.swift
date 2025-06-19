//
//  BeerConfiguration.swift
//  ITwea - Beer Drinking Simulation
//
//  Created by Jess Cadena on 6/19/25.
//

import SwiftUI
import SpriteKit

/// Centralized configuration for beer simulation parameters
struct BeerConfiguration {
    
    // MARK: - Physics Configuration
    struct Physics {
        /// Liquid density (0.1 - 2.0)
        static let liquidDensity: CGFloat = 0.8
        
        /// Foam density (0.1 - 1.0)
        static let foamDensity: CGFloat = 0.3
        
        /// Bubble density (0.05 - 0.5)
        static let bubbleDensity: CGFloat = 0.1
        
        /// Gravity scale multiplier (0.1 - 2.0)
        static let gravityScale: CGFloat = 0.5
        
        /// Damping factor for liquid movement (0.1 - 1.0)
        static let damping: CGFloat = 0.8
        
        /// Foam damping multiplier (1.0 - 3.0)
        static let foamDampingMultiplier: CGFloat = 1.5
        
        /// Bubble damping factor (0.1 - 1.0)
        static let bubbleDamping: CGFloat = 0.3
        
        /// Tilt sensitivity (0.1 - 2.0)
        static let tiltSensitivity: CGFloat = 0.5
        
        /// Force multiplier for tilt effects (50 - 200)
        static let tiltForceMultiplier: CGFloat = 100
    }
    
    // MARK: - Visual Configuration
    struct Visual {
        /// Beer liquid color
        static let beerColor = SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.8)
        
        /// Beer foam color
        static let foamColor = SKColor(red: 1.0, green: 1.0, blue: 0.9, alpha: 0.9)
        
        /// Bubble color
        static let bubbleColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
        
        /// Glass border color
        static let glassBorderColor = SKColor.white.withAlphaComponent(0.3)
        
        /// Glass border width
        static let glassBorderWidth: CGFloat = 2
        
        /// Liquid border width
        static let liquidBorderWidth: CGFloat = 1
        
        /// Foam border width
        static let foamBorderWidth: CGFloat = 1
        
        /// Bubble border width
        static let bubbleBorderWidth: CGFloat = 1
    }
    
    // MARK: - Glass Configuration
    struct Glass {
        /// Glass width
        static let width: CGFloat = 120
        
        /// Glass height
        static let height: CGFloat = 200
        
        /// Corner radius for rounded glass
        static let cornerRadius: CGFloat = 20
        
        /// Liquid width (slightly smaller than glass)
        static let liquidWidth: CGFloat = 100
        
        /// Liquid height multiplier
        static let liquidHeightMultiplier: CGFloat = 180
        
        /// Foam height
        static let foamHeight: CGFloat = 20
        
        /// Tilt offset multiplier
        static let tiltOffsetMultiplier: CGFloat = 20
    }
    
    // MARK: - Animation Configuration
    struct Animation {
        /// Bubble creation interval (seconds)
        static let bubbleInterval: TimeInterval = 0.5
        
        /// Bubble rise duration (seconds)
        static let bubbleRiseDuration: TimeInterval = 3.0
        
        /// Bubble fade duration (seconds)
        static let bubbleFadeDuration: TimeInterval = 2.0
        
        /// Minimum bubble radius
        static let minBubbleRadius: CGFloat = 2
        
        /// Maximum bubble radius
        static let maxBubbleRadius: CGFloat = 6
        
        /// Bubble spawn area width
        static let bubbleSpawnWidth: CGFloat = 100
        
        /// Bubble spawn Y position
        static let bubbleSpawnY: CGFloat = -90
        
        /// Bubble rise distance
        static let bubbleRiseDistance: CGFloat = 200
        
        /// Scene update frequency (FPS)
        static let updateFrequency: Double = 30.0
    }
    
    // MARK: - Audio Configuration
    struct Audio {
        /// Default volume level (0.0 - 1.0)
        static let defaultVolume: Float = 0.7
        
        /// Drink sound volume multiplier
        static let drinkVolumeMultiplier: Float = 0.8
        
        /// Bubble sound volume multiplier
        static let bubbleVolumeMultiplier: Float = 0.5
        
        /// Audio session category
        static let sessionCategory: AVAudioSession.Category = .ambient
        
        /// Audio session mode
        static let sessionMode: AVAudioSession.Mode = .default
        
        /// Audio session options
        static let sessionOptions: AVAudioSession.CategoryOptions = [.mixWithOthers]
    }
    
    // MARK: - Motion Configuration
    struct Motion {
        /// Motion update interval (seconds)
        static let updateInterval: TimeInterval = 1.0 / 60.0
        
        /// Motion queue quality of service
        static let queueQualityOfService: QualityOfService = .userInteractive
        
        /// Motion queue max concurrent operations
        static let maxConcurrentOperations: Int = 1
    }
    
    // MARK: - UI Configuration
    struct UI {
        /// Background gradient colors
        static let backgroundColors: [Color] = [
            Color.black.opacity(0.8),
            Color.gray.opacity(0.6)
        ]
        
        /// Glass container background material
        static let glassBackgroundMaterial: Material = .ultraThinMaterial
        
        /// Instructions background material
        static let instructionsBackgroundMaterial: Material = .ultraThinMaterial
        
        /// Button corner radius
        static let buttonCornerRadius: CGFloat = 10
        
        /// Glass container corner radius
        static let glassContainerCornerRadius: CGFloat = 20
        
        /// SpriteKit scene corner radius
        static let sceneCornerRadius: CGFloat = 15
    }
}

// MARK: - Beer Types Configuration
extension BeerConfiguration {
    /// Predefined beer types with different visual properties
    enum BeerType: String, CaseIterable {
        case lager = "Lager"
        case ale = "Ale"
        case stout = "Stout"
        case wheat = "Wheat"
        case ipa = "IPA"
        
        var color: SKColor {
            switch self {
            case .lager:
                return SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.8)
            case .ale:
                return SKColor(red: 0.8, green: 0.6, blue: 0.1, alpha: 0.8)
            case .stout:
                return SKColor(red: 0.2, green: 0.1, blue: 0.05, alpha: 0.9)
            case .wheat:
                return SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.8)
            case .ipa:
                return SKColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 0.8)
            }
        }
        
        var foamColor: SKColor {
            switch self {
            case .lager, .ale, .wheat, .ipa:
                return SKColor(red: 1.0, green: 1.0, blue: 0.9, alpha: 0.9)
            case .stout:
                return SKColor(red: 0.8, green: 0.7, blue: 0.6, alpha: 0.9)
            }
        }
        
        var bubbleIntensity: Double {
            switch self {
            case .lager:
                return 1.0
            case .ale:
                return 0.8
            case .stout:
                return 0.3
            case .wheat:
                return 1.2
            case .ipa:
                return 0.9
            }
        }
    }
}

// MARK: - Customization Instructions
/*
 CUSTOMIZATION INSTRUCTIONS:
 
 1. PHYSICS ADJUSTMENTS:
    - Increase liquidDensity for thicker beer
    - Decrease damping for more fluid movement
    - Adjust gravityScale for different gravity effects
    - Modify tiltSensitivity for device responsiveness
 
 2. VISUAL CUSTOMIZATION:
    - Change beerColor for different beer types
    - Adjust transparency with alpha values
    - Modify glass dimensions in Glass struct
    - Customize bubble appearance and behavior
 
 3. ANIMATION TUNING:
    - Adjust bubbleInterval for bubble frequency
    - Modify bubbleRiseDuration for rise speed
    - Change updateFrequency for performance vs smoothness
 
 4. AUDIO SETTINGS:
    - Adjust volume levels for different sound effects
    - Modify audio session settings for background playback
    - Customize sound effect timing and intensity
 
 5. BEER TYPES:
    - Use predefined BeerType enum for different styles
    - Each type has optimized colors and bubble behavior
    - Easy to add new beer types by extending the enum
 
 6. PERFORMANCE OPTIMIZATION:
    - Reduce updateFrequency on older devices
    - Decrease bubbleInterval for fewer particles
    - Adjust physics complexity based on device capabilities
 */ 