//
//  ViewController.swift
//  AR Ruler
//
//  Created by Sheheryar Ahmed on 19/08/2019.
//  Copyright © 2019 The Sheheryar Ahmed. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var dotNodes=[SCNNode]()
    var textNode = SCNNode()
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints]
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count>=2{
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
            dotNodes=[SCNNode]()
        }
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResults.first{
                addDot(at:hitResult)
            }
        }
        
    }
    func addDot(at hitResult:ARHitTestResult){
        let dot = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dot.materials = [material]
        let dotNode = SCNNode()
       
        dotNode.position = SCNVector3(
            x: hitResult.worldTransform.columns.3.x,
            y: hitResult.worldTransform.columns.3.y,
            z: hitResult.worldTransform.columns.3.z)
       
        dotNode.geometry = dot
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count>=2{
            calculate()
        }
        
    }
    func calculate(){
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let distance = sqrt(
            pow(end.position.x - start.position.x , 2) +
            pow(end.position.y - start.position.y,2) +
            pow(end.position.z - end.position.z, 2)
        )
        updateText(text:"\(distance)" , atPosition:end.position)
    }
    
    func updateText(text:String , atPosition position:SCNVector3){
        
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text + "m", extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents=UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.1, position.z)
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)

        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
