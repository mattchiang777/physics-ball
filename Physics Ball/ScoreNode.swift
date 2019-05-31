//
//  ScoreNode.swift
//  Physics Ball
//
//  Created by Matthew Chiang on 5/31/19.
//  Copyright © 2019 Matthew Chiang. All rights reserved.
//

import Foundation
import SceneKit

class ScoreNode: SCNNode {
    
    init(withRadius radius: CGFloat, withScale scale: Float) {
        super.init()
        
        // Set up score node geometry and material
        let cylinderGeometry = SCNCylinder(radius: radius, height: radius * 0.2)
        cylinderGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        
        // Set up score nodes
        self.geometry = cylinderGeometry
        
        // Set up score node physics
        let cylinderPhysicsShape = SCNPhysicsShape(geometry: cylinderGeometry, options:[SCNPhysicsShape.Option.scale: scale])
        self.physicsBody = SCNPhysicsBody(type: .static, shape: cylinderPhysicsShape)
        
        self.physicsBody?.categoryBitMask = CollisionCategory.score.rawValue
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
