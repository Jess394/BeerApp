//
//  BeerScene.swift
//  ITwea - Beer Drinking Simulation
//
//  Created by Jess Cadena on 6/19/25.
//

import SpriteKit
import CoreMotion

/// SpriteKit scene for beer liquid simulation with physics
class BeerScene: SKScene {
    // MARK: - Properties
    private var beerContainer: SKShapeNode!
    private var beerLiquid: SKShapeNode!
    private var beerFoam: SKShapeNode!
    private var bubbleLayer: SKNode!
    private var physicsWorld: SKPhysicsWorld!
    
    // MARK: - Configuration
    private var beerLevel: Double = 1.0
    private var currentTilt: CGVector = .zero
    private var lastUpdateTime: TimeInterval = 0
    private var selectedBeerType: BeerConfiguration.BeerType = .lager
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupBeerContainer()
        setupBeerLiquid()
        setupBeerFoam()
        setupBubbleLayer()
        setupNotificationObservers()
        
        // Start bubble animation
        startBubbleAnimation()
    }
    
    // MARK: - Physics World Setup
    private func setupPhysicsWorld() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8 * BeerConfiguration.Physics.gravityScale)
        physicsWorld.contactDelegate = self
    }
    
    // MARK: - Beer Container Setup
    private func setupBeerContainer() {
        let containerPath = createGlassPath()
        beerContainer = SKShapeNode(path: containerPath)
        beerContainer.strokeColor = BeerConfiguration.Visual.glassBorderColor
        beerContainer.lineWidth = BeerConfiguration.Visual.glassBorderWidth
        beerContainer.fillColor = SKColor.clear
        beerContainer.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(beerContainer)
    }
    
    private func createGlassPath() -> CGPath {
        let path = CGMutablePath()
        let width = BeerConfiguration.Glass.width
        let height = BeerConfiguration.Glass.height
        let cornerRadius = BeerConfiguration.Glass.cornerRadius
        
        // Glass shape with rounded corners
        path.move(to: CGPoint(x: -width/2 + cornerRadius, y: -height/2))
        path.addLine(to: CGPoint(x: width/2 - cornerRadius, y: -height/2))
        path.addArc(center: CGPoint(x: width/2 - cornerRadius, y: -height/2 + cornerRadius),
                   radius: cornerRadius,
                   startAngle: .pi,
                   endAngle: .pi/2,
                   clockwise: false)
        path.addLine(to: CGPoint(x: width/2, y: height/2 - cornerRadius))
        path.addArc(center: CGPoint(x: width/2 - cornerRadius, y: height/2 - cornerRadius),
                   radius: cornerRadius,
                   startAngle: .pi/2,
                   endAngle: 0,
                   clockwise: false)
        path.addLine(to: CGPoint(x: -width/2 + cornerRadius, y: height/2))
        path.addArc(center: CGPoint(x: -width/2 + cornerRadius, y: height/2 - cornerRadius),
                   radius: cornerRadius,
                   startAngle: 0,
                   endAngle: -.pi/2,
                   clockwise: false)
        path.addLine(to: CGPoint(x: -width/2, y: -height/2 + cornerRadius))
        path.addArc(center: CGPoint(x: -width/2 + cornerRadius, y: -height/2 + cornerRadius),
                   radius: cornerRadius,
                   startAngle: -.pi/2,
                   endAngle: .pi,
                   clockwise: false)
        path.closeSubpath()
        
        return path
    }
    
    // MARK: - Beer Liquid Setup
    private func setupBeerLiquid() {
        beerLiquid = SKShapeNode()
        beerLiquid.fillColor = selectedBeerType.color
        beerLiquid.strokeColor = selectedBeerType.color.withAlphaComponent(0.5)
        beerLiquid.lineWidth = BeerConfiguration.Visual.liquidBorderWidth
        beerLiquid.position = CGPoint(x: frame.midX, y: frame.midY)
        
        // Add physics body
        let liquidBody = SKPhysicsBody()
        liquidBody.isDynamic = true
        liquidBody.affectedByGravity = true
        liquidBody.allowsRotation = false
        liquidBody.linearDamping = BeerConfiguration.Physics.damping
        liquidBody.angularDamping = BeerConfiguration.Physics.damping
        liquidBody.mass = BeerConfiguration.Physics.liquidDensity
        beerLiquid.physicsBody = liquidBody
        
        addChild(beerLiquid)
        updateBeerLiquidShape()
    }
    
    private func updateBeerLiquidShape() {
        let liquidPath = createLiquidPath(level: beerLevel, tilt: currentTilt)
        beerLiquid.path = liquidPath
    }
    
    private func createLiquidPath(level: Double, tilt: CGVector) -> CGPath {
        let path = CGMutablePath()
        let width = BeerConfiguration.Glass.liquidWidth
        let height = BeerConfiguration.Glass.liquidHeightMultiplier * CGFloat(level)
        let tiltOffset = CGPoint(
            x: tilt.dx * BeerConfiguration.Glass.tiltOffsetMultiplier,
            y: tilt.dy * BeerConfiguration.Glass.tiltOffsetMultiplier
        )
        
        // Create liquid surface with tilt
        let topLeft = CGPoint(x: -width/2 + tiltOffset.x, y: height/2 + tiltOffset.y)
        let topRight = CGPoint(x: width/2 + tiltOffset.x, y: height/2 + tiltOffset.y)
        let bottomLeft = CGPoint(x: -width/2, y: -height/2)
        let bottomRight = CGPoint(x: width/2, y: -height/2)
        
        path.move(to: bottomLeft)
        path.addLine(to: bottomRight)
        path.addLine(to: topRight)
        path.addLine(to: topLeft)
        path.closeSubpath()
        
        return path
    }
    
    // MARK: - Beer Foam Setup
    private func setupBeerFoam() {
        beerFoam = SKShapeNode()
        beerFoam.fillColor = selectedBeerType.foamColor
        beerFoam.strokeColor = selectedBeerType.foamColor.withAlphaComponent(0.7)
        beerFoam.lineWidth = BeerConfiguration.Visual.foamBorderWidth
        beerFoam.position = CGPoint(x: frame.midX, y: frame.midY)
        
        // Add physics body
        let foamBody = SKPhysicsBody()
        foamBody.isDynamic = true
        foamBody.affectedByGravity = true
        foamBody.allowsRotation = false
        foamBody.linearDamping = BeerConfiguration.Physics.damping * BeerConfiguration.Physics.foamDampingMultiplier
        foamBody.angularDamping = BeerConfiguration.Physics.damping * BeerConfiguration.Physics.foamDampingMultiplier
        foamBody.mass = BeerConfiguration.Physics.foamDensity
        beerFoam.physicsBody = foamBody
        
        addChild(beerFoam)
        updateBeerFoamShape()
    }
    
    private func updateBeerFoamShape() {
        let foamPath = createFoamPath(level: beerLevel, tilt: currentTilt)
        beerFoam.path = foamPath
    }
    
    private func createFoamPath(level: Double, tilt: CGVector) -> CGPath {
        let path = CGMutablePath()
        let width = BeerConfiguration.Glass.liquidWidth
        let foamHeight = BeerConfiguration.Glass.foamHeight
        let liquidHeight = BeerConfiguration.Glass.liquidHeightMultiplier * CGFloat(level)
        let tiltOffset = CGPoint(
            x: tilt.dx * BeerConfiguration.Glass.tiltOffsetMultiplier,
            y: tilt.dy * BeerConfiguration.Glass.tiltOffsetMultiplier
        )
        
        // Create foam layer on top of liquid
        let topLeft = CGPoint(x: -width/2 + tiltOffset.x, y: liquidHeight/2 + foamHeight + tiltOffset.y)
        let topRight = CGPoint(x: width/2 + tiltOffset.x, y: liquidHeight/2 + foamHeight + tiltOffset.y)
        let bottomLeft = CGPoint(x: -width/2 + tiltOffset.x * 0.5, y: liquidHeight/2 + tiltOffset.y)
        let bottomRight = CGPoint(x: width/2 + tiltOffset.x * 0.5, y: liquidHeight/2 + tiltOffset.y)
        
        path.move(to: bottomLeft)
        path.addLine(to: bottomRight)
        path.addLine(to: topRight)
        path.addLine(to: topLeft)
        path.closeSubpath()
        
        return path
    }
    
    // MARK: - Bubble Layer Setup
    private func setupBubbleLayer() {
        bubbleLayer = SKNode()
        bubbleLayer.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(bubbleLayer)
    }
    
    private func startBubbleAnimation() {
        let createBubble = SKAction.run { [weak self] in
            self?.createBubble()
        }
        
        let wait = SKAction.wait(forDuration: BeerConfiguration.Animation.bubbleInterval / selectedBeerType.bubbleIntensity)
        let sequence = SKAction.sequence([createBubble, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever)
    }
    
    private func createBubble() {
        let radius = CGFloat.random(in: BeerConfiguration.Animation.minBubbleRadius...BeerConfiguration.Animation.maxBubbleRadius)
        let bubble = SKShapeNode(circleOfRadius: radius)
        bubble.fillColor = BeerConfiguration.Visual.bubbleColor
        bubble.strokeColor = BeerConfiguration.Visual.bubbleColor.withAlphaComponent(0.8)
        bubble.lineWidth = BeerConfiguration.Visual.bubbleBorderWidth
        
        // Random position at bottom of glass
        let x = CGFloat.random(in: -BeerConfiguration.Animation.bubbleSpawnWidth/2...BeerConfiguration.Animation.bubbleSpawnWidth/2)
        let y = BeerConfiguration.Animation.bubbleSpawnY
        bubble.position = CGPoint(x: x, y: y)
        
        // Add physics
        let bubbleBody = SKPhysicsBody(circleOfRadius: bubble.frame.width / 2)
        bubbleBody.isDynamic = true
        bubbleBody.affectedByGravity = true
        bubbleBody.allowsRotation = false
        bubbleBody.linearDamping = BeerConfiguration.Physics.bubbleDamping
        bubbleBody.mass = BeerConfiguration.Physics.bubbleDensity
        bubble.physicsBody = bubbleBody
        
        bubbleLayer.addChild(bubble)
        
        // Remove bubble after animation
        let moveUp = SKAction.moveBy(x: 0, y: BeerConfiguration.Animation.bubbleRiseDistance, duration: BeerConfiguration.Animation.bubbleRiseDuration)
        let fadeOut = SKAction.fadeOut(withDuration: BeerConfiguration.Animation.bubbleFadeDuration)
        let group = SKAction.group([moveUp, fadeOut])
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([group, remove])
        
        bubble.run(sequence)
    }
    
    // MARK: - Notification Observers
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateBeerLevel(_:)),
            name: .updateBeerLevel,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateDeviceMotion(_:)),
            name: .updateDeviceMotion,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateBeerType(_:)),
            name: .updateBeerType,
            object: nil
        )
    }
    
    @objc private func updateBeerLevel(_ notification: Notification) {
        guard let level = notification.object as? Double else { return }
        beerLevel = level
        updateBeerLiquidShape()
        updateBeerFoamShape()
    }
    
    @objc private func updateDeviceMotion(_ notification: Notification) {
        guard let motion = notification.object as? CMDeviceMotion else { return }
        
        // Update tilt based on device motion
        let roll = motion.normalizedRoll
        let pitch = motion.normalizedPitch
        
        currentTilt = CGVector(
            dx: CGFloat(roll) * BeerConfiguration.Physics.tiltSensitivity,
            dy: CGFloat(pitch) * BeerConfiguration.Physics.tiltSensitivity
        )
        
        // Update physics world gravity
        physicsWorld.gravity = CGVector(
            dx: CGFloat(motion.gravity.x) * 9.8 * BeerConfiguration.Physics.gravityScale,
            dy: CGFloat(motion.gravity.y) * 9.8 * BeerConfiguration.Physics.gravityScale
        )
        
        updateBeerLiquidShape()
        updateBeerFoamShape()
    }
    
    @objc private func updateBeerType(_ notification: Notification) {
        guard let beerType = notification.object as? BeerConfiguration.BeerType else { return }
        selectedBeerType = beerType
        
        // Update colors
        beerLiquid.fillColor = selectedBeerType.color
        beerLiquid.strokeColor = selectedBeerType.color.withAlphaComponent(0.5)
        beerFoam.fillColor = selectedBeerType.foamColor
        beerFoam.strokeColor = selectedBeerType.foamColor.withAlphaComponent(0.7)
        
        // Restart bubble animation with new intensity
        removeAction(forKey: "bubbleAnimation")
        startBubbleAnimation()
    }
    
    // MARK: - Scene Update
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // Limit update frequency
        if currentTime - lastUpdateTime < 1.0 / BeerConfiguration.Animation.updateFrequency {
            return
        }
        lastUpdateTime = currentTime
        
        // Update liquid physics
        updateLiquidPhysics()
    }
    
    private func updateLiquidPhysics() {
        // Apply additional forces based on tilt
        let tiltForce = CGVector(
            dx: currentTilt.dx * BeerConfiguration.Physics.tiltForceMultiplier,
            dy: currentTilt.dy * BeerConfiguration.Physics.tiltForceMultiplier
        )
        
        beerLiquid.physicsBody?.applyForce(tiltForce)
        beerFoam.physicsBody?.applyForce(tiltForce)
    }
}

// MARK: - Physics Contact Delegate
extension BeerScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Handle collisions between liquid, foam, and bubbles
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let updateBeerLevel = Notification.Name("updateBeerLevel")
    static let updateDeviceMotion = Notification.Name("updateDeviceMotion")
    static let updateBeerType = Notification.Name("updateBeerType")
} 