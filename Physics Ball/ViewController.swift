//
//  ViewController.swift
//  Physics Ball
//
//  Created by Matthew Chiang on 5/26/19.
//  Copyright © 2019 Matthew Chiang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addHoopBtn: UIButton!
    
    var currentNode:SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        registerGestureRecognizer()
        
    }
    
    func registerGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        sceneView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        // scene view to be accessed
        // access the POV of the scene view aka the center camera point
        guard let sceneView = gestureRecognizer.view as? ARSCNView else {
            return
        }
        
        guard let centerPoint = sceneView.pointOfView else {
            return
        }
        
        // transform matrix (contains orientation and location of the camera to create the position of the camera to place the ball)
        let cameraTransform = centerPoint.transform
        
        let cameraLocation = SCNVector3(x: cameraTransform.m41, y: cameraTransform.m42, z: cameraTransform.m43)
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
        
        //
        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y, cameraLocation.z + cameraOrientation.z)
        
        let ball = SCNSphere(radius: 0.12)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "basketballSkin.png")
        ball.materials = [material]
        
        let ballNode = SCNNode(geometry: ball)
        ballNode.position = cameraPosition
        ballNode.eulerAngles = SCNVector3Make(0, 0, -.pi * 0.5)
        sceneView.scene.rootNode.addChildNode(ballNode)
        
        // Physics
        let physicsShape = SCNPhysicsShape(node: ballNode, options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        physicsBody.mass = 0.6237
        physicsBody.restitution = 0.55
        physicsBody.allowsResting = false
        
        ballNode.physicsBody = physicsBody
        
        let forceVector:Float = 7
        ballNode.physicsBody?.applyForce(SCNVector3(x: cameraOrientation.x * forceVector, y: cameraOrientation.y * forceVector, z: cameraOrientation.z * forceVector), asImpulse: true)
        
//        ballNode.physicsBody?.applyTorque(SCNVector4(1, 0, 0, 1), asImpulse: true)
    }
    
    func addBackboard() {
        guard let backboardScene = SCNScene(named: "art.scnassets/BasketballHoop_Prototype.dae") else {
            return
        }
        
        guard let backboardNode = backboardScene.rootNode.childNode(withName: "NBA_Hoop", recursively: false) else {
            return
        }
        
        guard let innerBackboardNode = backboardNode.childNode(withName: "BackBoard_Glass", recursively: true) else {
            return
        }
        
        let backboardNodeSize = innerBackboardNode.boundingBox
        let size = SCNVector3(x: backboardNodeSize.max.x - backboardNodeSize.min.x, y: backboardNodeSize.max.y - backboardNodeSize.min.y, z: backboardNodeSize.max.z - backboardNodeSize.min.z)
        let scale = 1.828 / size.z
        print(size)
        
        backboardNode.position = SCNVector3(x: 0, y: 0.5, z: -4.3)
        backboardNode.scale = SCNVector3(scale, scale, scale)
        
        // Physics
        let physicsShape = SCNPhysicsShape(node: backboardNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        
        backboardNode.physicsBody = physicsBody
        
        sceneView.scene.rootNode.addChildNode(backboardNode)
        
        currentNode = backboardNode
        
        // Debug
        let line = Utilities.generateLine(startNode: sceneView.pointOfView!, endNode: currentNode)
        sceneView.scene.rootNode.addChildNode(line)
    }
    
    func horizontalAction(node:SCNNode) {
        let leftAction = SCNAction.move(by: SCNVector3(x: -1, y: 0, z: 0), duration: 3)
        let rightAction = SCNAction.move(by: SCNVector3(x: 1, y: 0, z: 0), duration: 3)
        
        let actionSequence = SCNAction.sequence([leftAction, rightAction])
        
        node.runAction(SCNAction.repeat(actionSequence, count: 4))
    }
    
    func roundAction(node:SCNNode) {
        let upLeft = SCNAction.move(by: SCNVector3(x: -1, y: 1, z: 0), duration: 2)
        let downRight = SCNAction.move(by: SCNVector3(x: 1, y: -1, z: 0), duration: 2)
        let downLeft = SCNAction.move(by: SCNVector3(x: -1, y: -1, z: 0), duration: 2)
        let upRight = SCNAction.move(by: SCNVector3(x: 1, y: 1, z: 0), duration: 2)
        
        let actionSequence = SCNAction.sequence([upLeft, downRight, downLeft, upRight])
        
        node.runAction(SCNAction.repeat(actionSequence, count: 2))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    @IBAction func addHoop(_ sender: Any) {
        addBackboard()
        addHoopBtn.isHidden = true
    }
    
    @IBAction func startRoundAction(_ sender: Any) {
        roundAction(node: currentNode)
    }
    
    
    @IBAction func stopAllActions(_ sender: Any) {
        currentNode.removeAllActions()
    }
    
    
    @IBAction func startHorizontalAction(_ sender: Any) {
        horizontalAction(node: currentNode)
    }
}
