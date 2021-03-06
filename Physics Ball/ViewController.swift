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



class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, BasketballDelegate, ARSessionDelegate {
    

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addHoopBtn: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var backboard: SCNNode!
    var score: Int = 0
    var currentBasketballNode: Basketball!
    weak var delegate: ARSessionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
        sceneView.debugOptions = .showPhysicsShapes
        
        // Create a new scene
        let scene = SCNScene()
        scene.physicsWorld.contactDelegate = self
        
        // Set the scene to the view
        sceneView.scene = scene
        
        
        registerGestureRecognizer()
        
    }
    
    func registerGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        sceneView.addGestureRecognizer(tap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        
        sceneView.addGestureRecognizer(longPress)
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        // scene view to be accessed
        // access the POV of the scene view aka the center camera point
//        guard let sceneView = gestureRecognizer.view as? ARSCNView else {
//            return
//        }
//
//        guard let centerPoint = sceneView.pointOfView else {
//            return
//        }
//
//        // transform matrix (contains orientation and location of the camera to create the position of the camera to place the ball)
//        let cameraTransform = centerPoint.transform
//
//        let cameraLocation = SCNVector3(x: cameraTransform.m41, y: cameraTransform.m42, z: cameraTransform.m43)
//        let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
//        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y, cameraLocation.z + cameraOrientation.z)
//
//        let basketballNode = self.createBasketball(withPosition: cameraPosition, andOrientation: cameraOrientation)
//
//        sceneView.scene.rootNode.addChildNode(basketballNode)
    }
    
    @objc func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        // access the POV of the scene view aka the center camera point
        guard let sceneView = gestureRecognizer.view as? ARSCNView else {
            return
        }
        
        guard let centerPoint = sceneView.pointOfView else {
            return
        }
        
        // get the camera node and add basketball as a child
        let cameraNode = sceneView.pointOfView
        
        // transform matrix (contains orientation and location of the camera to create the position of the camera to place the ball)
        let cameraTransform = centerPoint.transform
        
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
        
        
        if (gestureRecognizer.state == UIGestureRecognizer.State.began) {

            print("long press began")
            
            self.currentBasketballNode = self.createBasketball(withPosition: SCNVector3(0, 0, 0), andOrientation: cameraOrientation)
            cameraNode?.addChildNode(self.currentBasketballNode)
            
        }
        
        else if (gestureRecognizer.state == UIGestureRecognizer.State.ended) {
            print("long press ended")
            let forceVector:Float = 6
            
            let ballNode = self.currentBasketballNode.childNode(withName: "ball", recursively: true)
            
            ballNode?.physicsBody?.isAffectedByGravity = true
            ballNode?.physicsBody?.applyForce(SCNVector3(x: (ballNode?.position.x)! * forceVector, y: (ballNode?.position.y)! * forceVector, z: (ballNode?.position.z)! * forceVector), asImpulse: true)
            
            self.currentBasketballNode = nil
        }
        
    }
    
// Add elements
    
    func createBasketball(withPosition position: SCNVector3, andOrientation orientation: SCNVector3) -> Basketball{
        let baskeball = Basketball(position: position, orientation: orientation)
        baskeball.delegate = self
        
        return baskeball
    }
    
    func addBackboard() {
        let backboardNode = Hoop()
        
        sceneView.scene.rootNode.addChildNode(backboardNode)
        
        backboard = backboardNode
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
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if ((self.currentBasketballNode) != nil) {
        
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -1
            let cameraTransform = frame.camera.transform
            
            let ballNode = self.currentBasketballNode.childNode(withName: "ball", recursively: true)
            ballNode?.simdTransform = matrix_multiply(cameraTransform, translation)

        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // Buttons for Game Modes
    
    @IBAction func addHoop(_ sender: Any) {
        addBackboard()
        addHoopBtn.isHidden = true
    }
    
    @IBAction func startRoundAction(_ sender: Any) {
        GameModes.roundAction(node: backboard)
    }
    
    
    @IBAction func stopAllActions(_ sender: Any) {
        backboard.removeAllActions()
    }
    
    
    @IBAction func startHorizontalAction(_ sender: Any) {
        GameModes.horizontalAction(node: backboard)
    }
    
    // Collisions
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if (contact.nodeA.physicsBody?.contactTestBitMask == contact.nodeB.physicsBody?.categoryBitMask || contact.nodeB.physicsBody?.contactTestBitMask == contact.nodeA.physicsBody?.categoryBitMask) {
            
            if (contact.nodeA.name == "ball" && contact.nodeB is ScoreNode) {
                (contact.nodeA.parent as! Basketball).didHitScoreNode(node: contact.nodeB as! ScoreNode)
            } else if (contact.nodeA is ScoreNode && contact.nodeB.name == "ball") {
                (contact.nodeB.parent as! Basketball).didHitScoreNode(node: contact.nodeA as! ScoreNode)
            }
        }
    }
    
    func didScore(withBall ball: Basketball) {
        print("SCORE!!!!!")
        self.score += 1
        scoreLabel.text = String(self.score)
    }
    
    
}
