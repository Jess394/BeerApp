# 🍺 Beer Drinking Simulation App

A realistic iOS beer drinking simulation built with SwiftUI and SpriteKit that responds to device motion. Tilt your iPhone to see the beer slosh realistically with animated foam and bubbles!

## ✨ Features

- **Realistic Fluid Physics**: Beer liquid responds to device tilt using CoreMotion
- **Animated Elements**: Foam, bubbles, and liquid surface animations
- **Sound Effects**: Pouring, drinking, and bubble sounds
- **Multiple Beer Types**: Lager, Ale, Stout, Wheat, and IPA with different colors and bubble intensities
- **Interactive Controls**: Adjust beer level, pour, refill, and toggle audio
- **Modular Architecture**: Clean, well-documented code structure
- **Hot Reload Compatible**: Works with InjectionIII for rapid development

## 🛠️ Requirements

- iOS 17.0+
- Xcode 15.0+
- iPhone with motion sensors (CoreMotion)
- Swift 5.9+

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ITwea.git
   cd ITwea
   ```

2. **Open in Xcode**
   ```bash
   open ITwea.xcodeproj
   ```

3. **Build and Run**
   - Select your target device (iPhone recommended for motion features)
   - Press `Cmd+R` to build and run

## 📱 Usage

### Basic Controls
- **Tilt Device**: Tilt your iPhone to see the beer slosh realistically
- **Beer Level Slider**: Adjust the amount of beer in the glass
- **Pour Button**: Add beer with sound effects
- **Refill Button**: Reset to a full glass
- **Audio Toggle**: Turn sound effects on/off
- **Beer Type Selector**: Choose from different beer styles

### Beer Types
- **Lager**: Classic golden color with moderate bubbles
- **Ale**: Darker amber with fewer bubbles
- **Stout**: Dark brown with minimal bubbles
- **Wheat**: Light golden with lots of bubbles
- **IPA**: Amber with moderate bubbles

## 🏗️ Project Structure

```
ITwea/
├── ITwea/
│   ├── ITweaApp.swift          # Main app entry point
│   ├── ContentView.swift       # Main SwiftUI view
│   ├── BeerScene.swift         # SpriteKit physics scene
│   ├── MotionManager.swift     # CoreMotion handling
│   ├── AudioManager.swift      # Sound effects
│   ├── BeerConfiguration.swift # Centralized configuration
│   └── Assets.xcassets/        # App assets
├── ITweaTests/                 # Unit tests
└── ITweaUITests/              # UI tests
```

## ⚙️ Configuration

All customization parameters are centralized in `BeerConfiguration.swift`:

### Physics Settings
```swift
// Adjust liquid behavior
BeerConfiguration.Physics.liquidDensity = 0.8
BeerConfiguration.Physics.damping = 0.8
BeerConfiguration.Physics.gravityScale = 0.5
BeerConfiguration.Physics.tiltSensitivity = 0.5
```

### Visual Settings
```swift
// Customize colors and appearance
BeerConfiguration.Visual.beerColor = SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.8)
BeerConfiguration.Glass.width = 120
BeerConfiguration.Glass.height = 200
```

### Animation Settings
```swift
// Control bubble behavior
BeerConfiguration.Animation.bubbleInterval = 0.5
BeerConfiguration.Animation.bubbleRiseDuration = 3.0
BeerConfiguration.Animation.updateFrequency = 30.0
```

## 🎵 Audio Setup

### Using Placeholder Sounds (Default)
The app includes generated placeholder sounds. No additional setup required.

### Using Custom Audio Files
1. Add audio files to your Xcode project:
   - `pour_sound.wav` - Liquid pouring sound
   - `drink_sound.wav` - Gulping/drinking sound
   - `bubble_sound.wav` - Bubbling/fizzing sound
   - `reset_sound.wav` - Glass refill sound

2. Update `AudioManager.swift`:
   ```swift
   private func createPlaceholderSounds() {
       pourPlayer = loadAudioFile(named: "pour_sound", withExtension: "wav")
       drinkPlayer = loadAudioFile(named: "drink_sound", withExtension: "wav")
       bubblePlayer = loadAudioFile(named: "bubble_sound", withExtension: "wav")
       resetPlayer = loadAudioFile(named: "reset_sound", withExtension: "wav")
   }
   ```

### Recommended Audio Specifications
- **Format**: WAV or MP3
- **Sample Rate**: 44.1 kHz
- **Duration**: 0.5-2.0 seconds
- **Volume**: Normalized to -12dB

## 🔧 Development

### Hot Reloading with InjectionIII
1. Install InjectionIII from the App Store
2. Add to your project:
   ```swift
   #if DEBUG
   import InjectionIII
   #endif
   ```
3. Enable hot reloading for rapid development

### Adding New Beer Types
1. Extend `BeerConfiguration.BeerType`:
   ```swift
   case porter = "Porter"
   ```
2. Add color and bubble properties:
   ```swift
   var color: SKColor {
       case .porter:
           return SKColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 0.9)
   }
   ```

### Performance Optimization
- Reduce `updateFrequency` on older devices
- Decrease `bubbleInterval` for fewer particles
- Adjust physics complexity based on device capabilities

## 🧪 Testing

### Unit Tests
```bash
# Run unit tests
xcodebuild test -scheme ITwea -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI Tests
```bash
# Run UI tests
xcodebuild test -scheme ITwea -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ITweaUITests
```

## 📋 Troubleshooting

### Common Issues

**Motion not working**
- Ensure device has motion sensors
- Check CoreMotion permissions
- Test on physical device (simulator has limited motion support)

**Audio not playing**
- Check device volume
- Verify audio session setup
- Ensure audio files are properly added to bundle

**Performance issues**
- Reduce animation complexity
- Lower update frequency
- Test on target device

### Debug Mode
Enable debug logging by setting:
```swift
#if DEBUG
print("Debug: Motion data received")
#endif
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Apple for CoreMotion and SpriteKit frameworks
- SwiftUI for the modern UI framework
- The iOS development community for inspiration

## 📞 Support

For questions or issues:
- Create an issue on GitHub
- Check the troubleshooting section
- Review the configuration documentation

---

**Enjoy your virtual beer! 🍺**
