//
//  BeerScene.swift
//  ITwea - Twisted Tea Simulation
//
//  Created by Jess Cadena on 6/19/25.
//

import SpriteKit
import CoreMotion

/// SpriteKit scene for Twisted Tea simulation with physics-based liquid effects
class TeaScene: SKScene {
    
    // MARK: - Properties
    private var glassNode: SKShapeNode!
    private var liquidNode: SKShapeNode!
    private var foamNode: SKShapeNode!
    private var bubbleNodes: [SKShapeNode] = []
    
    private var motionManager: CMMotionManager?
    private var lastUpdateTime: TimeInterval = 0
    
    private var currentTeaType: TeaConfiguration.TeaType = .original
    private var liquidLevel: CGFloat = 1.0 // 0.0 to 1.0
    private var isPouring = false
    private var isDrinking = false
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        print("TeaScene: Scene moved to view")
        setupScene()
        setupPhysics()
        setupGlass()
        setupLiquid()
        setupFoam()
        setupMotionManager()
        setupNotificationObservers()
        startBubbleAnimation()
    }
    
    override func willMove(from view: SKView) {
        print("TeaScene: Scene will move from view")
        stopMotionManager()
        removeNotificationObservers()
    }
    
    // MARK: - Scene Setup
    private func setupScene() {
        backgroundColor = .clear
        scaleMode = .aspectFit
        
        // Configure physics world
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8 * TeaConfiguration.Physics.gravityScale)
        physicsWorld.speed = 1.0
        
        print("TeaScene: Scene size is \(size), scaleMode is \(scaleMode)")
    }
    
    private func setupPhysics() {
        // Physics world is already configured in setupScene
        print("TeaScene: Physics world configured")
    }
    
    // MARK: - Glass Setup
    private func setupGlass() {
        // Calculate center position for the glass
        let centerX = size.width / 2 - TeaConfiguration.Glass.width / 2 - 50
        let centerY = size.height / 2 - TeaConfiguration.Glass.height / 2 - 50
        
        let glassPath = UIBezierPath(roundedRect: CGRect(
            x: 0,
            y: 0,
            width: TeaConfiguration.Glass.width,
            height: TeaConfiguration.Glass.height
        ), cornerRadius: TeaConfiguration.Glass.cornerRadius)
        
        glassNode = SKShapeNode(path: glassPath.cgPath)
        glassNode.position = CGPoint(x: centerX + TeaConfiguration.Glass.width / 2, y: centerY + TeaConfiguration.Glass.height / 2)
        glassNode.zPosition = 1
        glassNode.fillColor = .clear
        glassNode.strokeColor = TeaConfiguration.Visual.glassBorderColor
        glassNode.lineWidth = TeaConfiguration.Visual.glassBorderWidth
        glassNode.name = "glass"
        
        // Add invisible physics body to contain the liquid
        let glassBody = SKPhysicsBody(rectangleOf: CGSize(
            width: TeaConfiguration.Glass.width,
            height: TeaConfiguration.Glass.height
        ))
        glassBody.isDynamic = false
        glassBody.affectedByGravity = false
        glassBody.categoryBitMask = 4 // Glass boundary
        glassBody.contactTestBitMask = 1 | 2 | 3 // Liquid, foam, bubbles
        glassBody.collisionBitMask = 1 | 2 | 3 // Liquid, foam, bubbles
        glassBody.friction = 0.0
        glassBody.restitution = 0.0
        
        glassNode.physicsBody = glassBody
        
        addChild(glassNode)
        print("TeaScene: Glass node added at position \(glassNode.position)")
    }
    
    // MARK: - Liquid Setup
    private func setupLiquid() {
        updateLiquid()
    }
    
    private func updateLiquid() {
        // Remove existing liquid node
        liquidNode?.removeFromParent()
        
        let liquidHeight = TeaConfiguration.Glass.liquidHeightMultiplier * liquidLevel
        let glassCenterX = size.width / 2
        let glassCenterY = size.height / 2
        let liquidY = glassCenterY - TeaConfiguration.Glass.height / 2 + liquidHeight / 2 // Center the liquid at its bottom
        
        let liquidPath = UIBezierPath(roundedRect: CGRect(
            x: 0, // Center the path
            y: 0, // Center the path
            width: TeaConfiguration.Glass.liquidWidth,
            height: liquidHeight
        ), cornerRadius: TeaConfiguration.Glass.cornerRadius - 5)
        
        liquidNode = SKShapeNode(path: liquidPath.cgPath)
        liquidNode.position = CGPoint(x: glassCenterX, y: liquidY) // Position at bottom of glass
        liquidNode.zPosition = 2
        liquidNode.fillColor = currentTeaType.color
        liquidNode.strokeColor = currentTeaType.color.withAlphaComponent(0.3)
        liquidNode.lineWidth = TeaConfiguration.Visual.liquidBorderWidth
        liquidNode.name = "liquid"
        
        // Add physics body for liquid simulation
        let liquidBody = SKPhysicsBody(rectangleOf: CGSize(
            width: TeaConfiguration.Glass.liquidWidth,
            height: liquidHeight
        ))
        liquidBody.isDynamic = true
        liquidBody.affectedByGravity = true
        liquidBody.density = TeaConfiguration.Physics.liquidDensity
        liquidBody.linearDamping = TeaConfiguration.Physics.damping
        liquidBody.angularDamping = TeaConfiguration.Physics.damping
        liquidBody.friction = 0.1
        liquidBody.restitution = 0.1
        liquidBody.categoryBitMask = 1
        liquidBody.contactTestBitMask = 4 // Glass boundary
        liquidBody.collisionBitMask = 4 // Glass boundary
        
        liquidNode.physicsBody = liquidBody
        
        addChild(liquidNode)
        print("TeaScene: Liquid node updated with level \(liquidLevel) at position \(liquidNode.position)")
    }
    
    // MARK: - Foam Setup
    private func setupFoam() {
        updateFoam()
    }
    
    private func updateFoam() {
        // Remove existing foam node
        foamNode?.removeFromParent()
        
        let foamHeight = TeaConfiguration.Glass.foamHeight * liquidLevel
        let liquidHeight = TeaConfiguration.Glass.liquidHeightMultiplier * liquidLevel
        let glassCenterX = size.width / 2
        let glassCenterY = size.height / 2
        let foamY = glassCenterY - TeaConfiguration.Glass.height / 2 + liquidHeight + foamHeight / 2 // Position on top of liquid
        
        let foamPath = UIBezierPath(roundedRect: CGRect(
            x: 0, // Center the path
            y: 0, // Center the path
            width: TeaConfiguration.Glass.liquidWidth,
            height: foamHeight
        ), cornerRadius: TeaConfiguration.Glass.cornerRadius - 5)
        
        foamNode = SKShapeNode(path: foamPath.cgPath)
        foamNode.position = CGPoint(x: glassCenterX, y: foamY)
        foamNode.zPosition = 3
        foamNode.fillColor = currentTeaType.foamColor
        foamNode.strokeColor = currentTeaType.foamColor.withAlphaComponent(0.3)
        foamNode.lineWidth = TeaConfiguration.Visual.foamBorderWidth
        foamNode.name = "foam"
        
        // Add physics body for foam simulation
        let foamBody = SKPhysicsBody(rectangleOf: CGSize(
            width: TeaConfiguration.Glass.liquidWidth,
            height: foamHeight
        ))
        foamBody.isDynamic = true
        foamBody.affectedByGravity = true
        foamBody.density = TeaConfiguration.Physics.foamDensity
        foamBody.linearDamping = TeaConfiguration.Physics.damping * TeaConfiguration.Physics.foamDampingMultiplier
        foamBody.angularDamping = TeaConfiguration.Physics.damping * TeaConfiguration.Physics.foamDampingMultiplier
        foamBody.friction = 0.2
        foamBody.restitution = 0.3
        foamBody.categoryBitMask = 2
        foamBody.contactTestBitMask = 4 // Glass boundary
        foamBody.collisionBitMask = 4 // Glass boundary
        
        foamNode.physicsBody = foamBody
        
        addChild(foamNode)
        print("TeaScene: Foam node updated at position \(foamNode.position)")
    }
    
    // MARK: - Motion Manager
    private func setupMotionManager() {
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = TeaConfiguration.Motion.updateInterval
        motionManager?.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            self.handleDeviceMotion(motion)
        }
        print("TeaScene: Motion manager started")
    }
    
    private func stopMotionManager() {
        motionManager?.stopDeviceMotionUpdates()
        motionManager = nil
        print("TeaScene: Motion manager stopped")
    }
    
    private func handleDeviceMotion(_ motion: CMDeviceMotion) {
        let tiltX = motion.attitude.roll * TeaConfiguration.Physics.tiltSensitivity
        let tiltY = motion.attitude.pitch * TeaConfiguration.Physics.tiltSensitivity
        
        // Apply tilt forces to liquid and foam
        let tiltForce = CGVector(
            dx: tiltX * TeaConfiguration.Physics.tiltForceMultiplier,
            dy: tiltY * TeaConfiguration.Physics.tiltForceMultiplier
        )
        
        liquidNode?.physicsBody?.applyForce(tiltForce)
        foamNode?.physicsBody?.applyForce(tiltForce)
        
        // Simulate drinking when tilted forward
        if tiltY > 0.3 && !isDrinking {
            isDrinking = true
            drinkTea()
        } else if tiltY <= 0.3 {
            isDrinking = false
        }
    }
    
    // MARK: - Bubble Animation
    private func startBubbleAnimation() {
        let bubbleAction = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.createBubble()
            },
            SKAction.wait(forDuration: TeaConfiguration.Animation.bubbleInterval)
        ])
        
        run(SKAction.repeatForever(bubbleAction), withKey: "bubbleAnimation")
        print("TeaScene: Bubble animation started")
    }
    
    private func createBubble() {
        let bubbleRadius = CGFloat.random(
            in: TeaConfiguration.Animation.minBubbleRadius...TeaConfiguration.Animation.maxBubbleRadius
        )
        
        let glassCenterX = size.width / 2
        let glassCenterY = size.height / 2
        
        let bubbleX = glassCenterX + CGFloat.random(
            in: -TeaConfiguration.Animation.bubbleSpawnWidth/2...TeaConfiguration.Animation.bubbleSpawnWidth/2
        )
        let bubbleY = glassCenterY - TeaConfiguration.Glass.height / 2 + TeaConfiguration.Animation.bubbleSpawnY
        
        let bubblePath = UIBezierPath(ovalIn: CGRect(
            x: -bubbleRadius,
            y: -bubbleRadius,
            width: bubbleRadius * 2,
            height: bubbleRadius * 2
        ))
        
        let bubbleNode = SKShapeNode(path: bubblePath.cgPath)
        bubbleNode.position = CGPoint(x: bubbleX, y: bubbleY)
        bubbleNode.zPosition = 4
        bubbleNode.fillColor = TeaConfiguration.Visual.bubbleColor
        bubbleNode.strokeColor = TeaConfiguration.Visual.bubbleColor.withAlphaComponent(0.6)
        bubbleNode.lineWidth = TeaConfiguration.Visual.bubbleBorderWidth
        bubbleNode.name = "bubble"
        
        // Add physics body for bubble
        let bubbleBody = SKPhysicsBody(circleOfRadius: bubbleRadius)
        bubbleBody.isDynamic = true
        bubbleBody.affectedByGravity = false
        bubbleBody.density = TeaConfiguration.Physics.bubbleDensity
        bubbleBody.linearDamping = TeaConfiguration.Physics.bubbleDamping
        bubbleBody.friction = 0.0
        bubbleBody.restitution = 0.8
        bubbleBody.categoryBitMask = 3
        bubbleBody.contactTestBitMask = 0
        bubbleBody.collisionBitMask = 0
        
        bubbleNode.physicsBody = bubbleBody
        
        addChild(bubbleNode)
        bubbleNodes.append(bubbleNode)
        
        // Animate bubble rising
        let riseAction = SKAction.moveBy(
            x: 0,
            y: TeaConfiguration.Animation.bubbleRiseDistance,
            duration: TeaConfiguration.Animation.bubbleRiseDuration
        )
        
        let fadeAction = SKAction.fadeOut(withDuration: TeaConfiguration.Animation.bubbleFadeDuration)
        let removeAction = SKAction.removeFromParent()
        
        let bubbleAnimation = SKAction.sequence([
            riseAction,
            fadeAction,
            removeAction
        ])
        
        bubbleNode.run(bubbleAnimation) { [weak self] in
            if let index = self?.bubbleNodes.firstIndex(of: bubbleNode) {
                self?.bubbleNodes.remove(at: index)
            }
        }
    }
    
    // MARK: - Tea Actions
    func pourTea() {
        guard !isPouring else { return }
        isPouring = true
        
        // Simulate pouring animation
        let pourAction = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.liquidLevel = min(1.0, self?.liquidLevel ?? 0.0 + 0.1)
                self?.updateLiquid()
                self?.updateFoam()
            },
            SKAction.wait(forDuration: 0.1)
        ])
        
        let pourSequence = SKAction.sequence([
            SKAction.repeat(pourAction, count: 10),
            SKAction.run { [weak self] in
                self?.isPouring = false
            }
        ])
        
        run(pourSequence)
        print("TeaScene: Pouring tea")
    }
    
    func refillTea() {
        liquidLevel = 1.0
        updateLiquid()
        updateFoam()
        print("TeaScene: Tea refilled")
    }
    
    func drinkTea() {
        guard liquidLevel > 0.0 else { return }
        
        liquidLevel = max(0.0, liquidLevel - 0.05)
        updateLiquid()
        updateFoam()
        print("TeaScene: Drinking tea, level: \(liquidLevel)")
    }
    
    func changeTeaType(_ teaType: TeaConfiguration.TeaType) {
        currentTeaType = teaType
        updateLiquid()
        updateFoam()
        print("TeaScene: Changed to \(teaType.rawValue) tea")
    }
    
    // MARK: - Scene Update
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Limit update frequency for performance
        if deltaTime < 1.0 / TeaConfiguration.Animation.updateFrequency {
            return
        }
        
        // Update bubble intensity based on tea type
        if Int(currentTime * 10) % Int(TeaConfiguration.Animation.bubbleInterval * 10) == 0 {
            let shouldCreateBubble = Double.random(in: 0...1) < currentTeaType.bubbleIntensity
            if shouldCreateBubble {
                createBubble()
            }
        }
    }
    
    // MARK: - Notification Handlers
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePourNotification),
            name: .pourTea,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRefillNotification),
            name: .refillTea,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTeaTypeChangeNotification),
            name: .changeTeaType,
            object: nil
        )
        
        print("TeaScene: Notification observers set up")
    }
    
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
        print("TeaScene: Notification observers removed")
    }
    
    @objc func handlePourNotification() {
        print("TeaScene: Received pour notification")
        pourTea()
    }
    
    @objc func handleRefillNotification() {
        print("TeaScene: Received refill notification")
        refillTea()
    }
    
    @objc func handleTeaTypeChangeNotification(_ notification: Notification) {
        if let teaType = notification.object as? TeaConfiguration.TeaType {
            print("TeaScene: Received tea type change notification for \(teaType.rawValue)")
            changeTeaType(teaType)
        }
    }
} 