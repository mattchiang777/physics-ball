//
//  Basketball.swift
//  Physics Ball
//
//  Created by Matthew Chiang on 5/29/19.
//  Copyright © 2019 Matthew Chiang. All rights reserved.
//

import Foundation
import SceneKit

class Basketball: SCNNode {
    
    
    init(position: SCNVector3, orientation: SCNVector3) {
        super.init()
        
        let ball = SCNSphere(radius: 0.12)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "basketballSkin.png")
        ball.materials = [material]
        
        let ballNode = SCNNode(geometry: ball)
        ballNode.position = position
        ballNode.eulerAngles = SCNVector3Make(0, 0, -.pi * 0.5)
        
        // Physics
        let physicsShape = SCNPhysicsShape(node: ballNode, options: nil)
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
        
        self.addChildNode(ballNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
