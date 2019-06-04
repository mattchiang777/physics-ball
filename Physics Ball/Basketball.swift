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
    
    private(set) var hitOrderArray: [ScoreNode] = [] {
        didSet {
            // check against the correct order. if it's wrong, they cheated. if it's right, set hasScored
            if (hitOrderArray.count == 2) {
                if (hitOrderArray.first?.name == "firstScoreNode" && hitOrderArray.last?.name == "secondScoreNode") {
                    self.hasScored = true
                } else {
                    print("cheated by throwing upwards")
                }
            }
        }
    }
    
    private(set) var hasScored: Bool = false {
        didSet {
            guard let delegate = self.delegate else {
                return
            }
            
            if oldValue != hasScored && hasScored == true {
                delegate.didScore(withBall: self)
            }
        }
    }
    
    init(position: SCNVector3, orientation: SCNVector3) {
//        self.enterScorePosition = enterScorePosition
        super.init()
        
        let ball = SCNSphere(radius: 0.12)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "basketballSkin.png")
        ball.materials = [material]
        
        let ballNode = SCNNode(geometry: ball)
        ballNode.name = "ball"
        ballNode.position = position
        ballNode.eulerAngles = SCNVector3Make(0, 0, -.pi * 0.5)
        
        // Physics
        let physicsShape = SCNPhysicsShape(node: ballNode, options: [SCNPhysicsShape.Option.scale: 0.8])
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        physicsBody.mass = 0.6237
        physicsBody.restitution = 0.55
        physicsBody.allowsResting = false
        physicsBody.isAffectedByGravity = false
        
        physicsBody.categoryBitMask = CollisionCategory.ball.rawValue
        physicsBody.contactTestBitMask = CollisionCategory.score.rawValue
        physicsBody.collisionBitMask = CollisionCategory.hoop.rawValue
        
        ballNode.physicsBody = physicsBody
        
        // Projectile strength
        let forceVector:Float = 6
        
//        ballNode.physicsBody?.applyForce(SCNVector3(x: orientation.x * forceVector, y: orientation.y * forceVector, z: orientation.z * forceVector), asImpulse: true)
        
        // Backspin
//        ballNode.physicsBody?.applyTorque(SCNVector4(0.5, 0, 0, 0.3), asImpulse: true)
        
        self.addChildNode(ballNode)
        
    }
    
    func didHitScoreNode(node: ScoreNode) {
        
        // push the score node into the array if it doesn't have it yet
        if (!self.hitOrderArray.contains(node)) {
            self.hitOrderArray.append(node)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
