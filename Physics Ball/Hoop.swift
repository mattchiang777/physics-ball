//
//  Backboard.swift
//  Physics Ball
//
//  Created by Matthew Chiang on 5/29/19.
//  Copyright © 2019 Matthew Chiang. All rights reserved.
//

import Foundation
import SceneKit

class Hoop: SCNNode {
    
    
    override init() {
        super.init()
        
        guard let backboardScene = SCNScene(named: "art.scnassets/BasketballHoop_Prototype.dae") else {
            return
        }
        
        guard let backboardNode = backboardScene.rootNode.childNode(withName: "NBA_Hoop", recursively: false) else {
            return
        }
        
        guard let innerBackboardNode = backboardNode.childNode(withName: "BackBoard_Glass", recursively: true) else {
            return
        }
        
        // Adjust backboard size in AR
        let backboardNodeSize = innerBackboardNode.boundingBox
        let size = SCNVector3(x: backboardNodeSize.max.x - backboardNodeSize.min.x, y: backboardNodeSize.max.y - backboardNodeSize.min.y, z: backboardNodeSize.max.z - backboardNodeSize.min.z)
        let scale = 1.828 / size.z
        
        backboardNode.position = SCNVector3(x: 0, y: 1, z: -0.2)
        backboardNode.scale = SCNVector3(scale, scale, scale)
        
        // Physics
        let physicsShape = SCNPhysicsShape(node: backboardNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        let physicsBody = SCNPhysicsBody(type: .kinematic, shape: physicsShape)
        
        physicsBody.categoryBitMask = CollisionCategory.hoop.rawValue
        physicsBody.contactTestBitMask = CollisionCategory.none.rawValue
        physicsBody.collisionBitMask = CollisionCategory.ball.rawValue
        
        backboardNode.physicsBody = physicsBody
        
        
        // Set up the score nodes
        // Get the rim
        guard let rimNode = backboardNode.childNode(withName: "Rim", recursively: true) else {
            return
        }
        
        // Set up score nodes
        let radius = CGFloat(rimNode.boundingBox.max.z - rimNode.boundingBox.min.z) * 0.25
        
        let firstScoreNode = ScoreNode(withRadius: radius, withScale: scale)
        let secondScoreNode = ScoreNode(withRadius: radius, withScale: scale)
        
        firstScoreNode.name = "firstScoreNode"
        secondScoreNode.name = "secondScoreNode"
        secondScoreNode.position = SCNVector3(0, -4, 0)
        
        // Add the score nodes to parent rim
        rimNode.addChildNode(firstScoreNode)
        rimNode.addChildNode(secondScoreNode)
        self.addChildNode(backboardNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
