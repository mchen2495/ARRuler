//
//  ViewController.swift
//  AR Ruler
//
//  Created by Michael Chen on 1/17/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
//        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
//
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
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
    
    //detecting touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /*if array already have two dots and user add another one that means user want to do
          new measurement, so we reset the array
         */
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                //removes dot from scene
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        //get loccation of where user touched
        if let touchLocation = touches.first?.location(in: sceneView){
            
            //changes touch location in 2d space (iphone screen) to 3d spaces through camera image
            guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) else{ return }
            
            let results = sceneView.session.raycast(query)
            
            //if empty that means user touch a point outside of the existing plane
            if let hitResult = results.first{
                
                addDot(at: hitResult)
                
                
            }
        }
    }
    
    func addDot(at hitResult: ARRaycastResult){
        
        //object to display
        let dotGeometry = SCNSphere(radius: 0.005)
        
        //how you want the object to look
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red   //base material for object
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        //where to place the dot
        dotNode.position = SCNVector3(
            x: hitResult.worldTransform.columns.3.x,
            y: hitResult.worldTransform.columns.3.y,
            z: hitResult.worldTransform.columns.3.z)

        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2{
            calculate()
        }
        
    }
    
    
    func calculate(){
        //get starting point
        let start = dotNodes[0]
        
        //get end point
        let end = dotNodes[1]
        
        print("Starting position is \(start.position)")
        print("Ending position is \(end.position)")
        
        //Using pythagorean thoerem to find distance between two 3d points
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        
        print(abs(distance))
        
        let absoluteValue = abs(distance)
        
        let lengthInInches = (absoluteValue * 39.3701)
        
        let text = String(format: "%.2f", lengthInInches)
        
        //updateText(text: "\(abs(distance))", atPosition: end.position)
        updateText(text: text, atPosition: end.position)
        
    }
    
    func updateText(text: String, atPosition position: SCNVector3){
        
        //clears previous text
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text + " inch" , extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        
        //where to display the text
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }

    
}
