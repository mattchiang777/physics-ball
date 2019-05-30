//
//  Basketball.swift
//  Physics Ball
//
//  Created by Matthew Chiang on 5/29/19.
//  Copyright © 2019 Matthew Chiang. All rights reserved.
//

import Foundation
import SceneKit

public protocol BasketballDelegate : NSObjectProtocol {
    func didScore(withBall ball: Basketball)
}

public class Basketball: SCNNode {
    
    weak var delegate: BasketballDelegate?
    var enterScorePosition: SCNVector3
    
    private(set) var hasScored: Bool = false {
        didSet{
            guard let delegate = self.delegate else {
                return
            }
            
            if oldValue != hasScored && hasScored == true {
                delegate.didScore(withBall: self)
            }
        }
    }
    
    init(position: SCNVector3, orientation: SCNVector3, enterScorePosition: SCNVector3) {
        self.enterScorePosition = enterScorePosition
        super.init()
        
        let ball = SCNSphere(radius: 0.12)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "basketballSkin.png")
        ball.materials = [material]
        
        let ballNode = SCNNode(geometry: ball)
        ballNode.position = position
        ballNode.eulerAngles = SCNVector3Make(0, 0, -.pi * 0.5)
        
        // Physics
        let physicsShape = SCNPhysicsShape(node: ballNode, options: [SCNPhysicsShape.Option.scale: 0.8])
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        physicsBody.mass = 0.6237
        physicsBody.restitution = 0.55
        physicsBody.allowsResting = false
        
        physicsBody.categoryBitMask = CollisionCategory.ball.rawValue
        physicsBody.contactTestBitMask = CollisionCategory.score.rawValue
        physicsBody.collisionBitMask = CollisionCategory.hoop.rawValue
        
        ballNode.physicsBody = physicsBody
        
        // Projectile strength
        let forceVector:Float = 6
        
        ballNode.physicsBody?.applyForce(SCNVector3(x: orientation.x * forceVector, y: orientation.y * forceVector, z: orientation.z * forceVector), asImpulse: true)
        
        // Backspin
        ballNode.physicsBody?.applyTorque(SCNVector4(0.5, 0, 0, 0.3), asImpulse: true)
        
        ballNode.name = "ball"
        
        self.addChildNode(ballNode)
        
    }
    
    func didEnterHoop(atPosition position: SCNVector3) {
        enterScorePosition = position
        print("enterScorePosition:", enterScorePosition)
    }
    
    func didExitHoop(atPosition exitScorePosition: SCNVector3, withDifferenceRequirement scoreNodeHeight: Float) {
        print("exitScorePosition:", exitScorePosition)
        print("scoreNodeHeight detected by ball:", scoreNodeHeight)
        if (exitScorePosition.y < enterScorePosition.y - scoreNodeHeight) {
            self.hasScored = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
