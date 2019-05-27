//
//  Utilities.swift
//  Physics Ball
//
//  Created by Matthew Chiang on 5/26/19.
//  Copyright © 2019 Matthew Chiang. All rights reserved.
//

import Foundation
import SceneKit

class Utilities {
    
    static func generateLine(startNode: SCNNode, endNode: SCNNode) -> SCNNode {
        
        let startPoint = startNode.simdTransform.columns.3
        let endPoint = endNode.simdTransform.columns.3
        
        // create a cylinder where radius is line thickness and height is the distance between end and start and orientation is ?
        let thickness = 0.002
        let vector = endPoint - startPoint
        let distance = length(vector)
        
        
        let cylinderGeometry = SCNCylinder(radius: CGFloat(thickness), height: CGFloat(distance))
        cylinderGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        let cylinderNode = SCNNode(geometry: cylinderGeometry)
        
        cylinderNode.simdLook(at: endNode.simdPosition, up: simd_float3(0, 0, -1), localFront: simd_float3(0, 1, 0))
        
        cylinderNode.position = startNode.position
        
        return cylinderNode
    }
    
}

