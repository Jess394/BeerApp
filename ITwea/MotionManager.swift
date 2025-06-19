//
//  MotionManager.swift
//  ITwea - Beer Drinking Simulation
//
//  Created by Jess Cadena on 6/19/25.
//

import Foundation
import CoreMotion
import Combine

/// Manages device motion data for beer simulation physics
class MotionManager: ObservableObject {
    // MARK: - Properties
    private let motionManager = CMMotionManager()
    
    @Published var deviceMotion: CMDeviceMotion?
    @Published var isMotionAvailable = false
    @Published var errorMessage: String?
    
    // MARK: - Configuration
    private let motionQueue = OperationQueue()
    
    init() {
        setupMotionQueue()
        checkMotionAvailability()
    }
    
    deinit {
        stopMotionUpdates()
    }
    
    // MARK: - Public Methods
    
    /// Request motion permissions and start monitoring
    func requestMotionPermissions() {
        guard motionManager.isDeviceMotionAvailable else {
            errorMessage = "Device motion is not available on this device"
            return
        }
        
        startMotionUpdates()
    }
    
    /// Stop motion updates
    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    // MARK: - Private Methods
    
    private func setupMotionQueue() {
        motionQueue.qualityOfService = BeerConfiguration.Motion.queueQualityOfService
        motionQueue.maxConcurrentOperationCount = BeerConfiguration.Motion.maxConcurrentOperations
    }
    
    private func checkMotionAvailability() {
        isMotionAvailable = motionManager.isDeviceMotionAvailable
    }
    
    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            errorMessage = "Device motion is not available"
            return
        }
        
        motionManager.deviceMotionUpdateInterval = BeerConfiguration.Motion.updateInterval
        
        motionManager.startDeviceMotionUpdates(to: motionQueue) { [weak self] motion, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Motion error: \(error.localizedDescription)"
                    return
                }
                
                self?.deviceMotion = motion
            }
        }
    }
}

// MARK: - Motion Data Extensions
extension CMDeviceMotion {
    /// Get normalized roll angle (-1 to 1)
    var normalizedRoll: Double {
        return atan2(attitude.rotationMatrix.m32, attitude.rotationMatrix.m33)
    }
    
    /// Get normalized pitch angle (-1 to 1)
    var normalizedPitch: Double {
        return atan2(-attitude.rotationMatrix.m31, sqrt(attitude.rotationMatrix.m32 * attitude.rotationMatrix.m32 + attitude.rotationMatrix.m33 * attitude.rotationMatrix.m33))
    }
    
    /// Get device tilt magnitude (0 to 1)
    var tiltMagnitude: Double {
        let roll = abs(normalizedRoll)
        let pitch = abs(normalizedPitch)
        return min(sqrt(roll * roll + pitch * pitch), 1.0)
    }
    
    /// Get gravity vector for fluid simulation
    var gravityVector: CGVector {
        return CGVector(
            dx: gravity.x,
            dy: gravity.y
        )
    }
} 