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
//        print(size)
        
        backboardNode.position = SCNVector3(x: 0, y: 0.5, z: -4.3)
        backboardNode.scale = SCNVector3(scale, scale, scale)
        
        // Physics
        let physicsShape = SCNPhysicsShape(node: backboardNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        
        physicsBody.categoryBitMask = CollisionCategory.hoop.rawValue
        physicsBody.contactTestBitMask = CollisionCategory.none.rawValue
        physicsBody.collisionBitMask = CollisionCategory.ball.rawValue
        
        backboardNode.physicsBody = physicsBody
        
        
        // Cylinder for contact inside the rim
        // Get the rim
        guard let rimNode = backboardNode.childNode(withName: "Rim", recursively: true) else {
            return
        }
        print(rimNode)
        // Get the rim position
//        let rimPosition = rimNode.position
        // Place cylinder at rim position
        
        
        
//        let radius = CGFloat(rimNode.boundingBoxSize.z * 0.5)
        
        let radius = CGFloat(rimNode.boundingBox.max.z - rimNode.boundingBox.min.z) * 0.5
        
        let cylinderGeometry = SCNCylinder(radius: radius, height: radius * 0.2)
        cylinderGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        let cylinderNode = SCNNode(geometry: cylinderGeometry)
        
        let cylinderPhysicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        
        cylinderPhysicsBody.categoryBitMask = CollisionCategory.score.rawValue
        cylinderPhysicsBody.contactTestBitMask = CollisionCategory.ball.rawValue
        cylinderPhysicsBody.collisionBitMask = CollisionCategory.none.rawValue
        
        cylinderNode.physicsBody = cylinderPhysicsBody
        
        
        rimNode.addChildNode(cylinderNode)
        
        
        self.addChildNode(backboardNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
