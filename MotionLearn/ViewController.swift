//
//  ViewController.swift
//  MotionLearn
//
//  Created by Amahstla . on 28/09/2019.
//  Copyright © 2019 VK. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
  var img: UIImage!
  
    override func viewDidLoad() {
        super.viewDidLoad()

                // Create a session configuration
                let configuration = ARWorldTrackingConfiguration()
        //        configuration.planeDetection = .vertical
              if #available(iOS 13.0, *) {
                configuration.frameSemantics = .personSegmentation
              } else {
                // Fallback on earlier versions
              }
                // Run the view's session
                sceneView.session.run(configuration)
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // Create a new scene
        let scene = SCNScene()

        // Set the scene to the view
        sceneView.scene = scene
        
        
      let size = CGSize(width: 0.15, height: 0.15)
      let ball = SCNPlane(width: size.width, height: size.height)
      
      let ballNode = SCNNode(geometry: ball)
      ballNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "mona-lisa")
//      let fov = sceneView.pointOfView?.camera?.fieldOfView ?? 0.0
//      print("fov = \(fov)")
//      let a: CGFloat = CGFloat(tanf((GLKMathDegreesToRadians(Float(fov/2.0)))))
//      let z = ((size.height / 2.0) / a)
        
      ballNode.position = SCNVector3Make(0, 0, -0.2)
      sceneView.pointOfView?.addChildNode(ballNode)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
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
  var didAdded = false
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as? , planeAnchor.alignment == .vertical else { return }
//      guard !didAdded, let a = anchor as? ARPlaneAnchor else {return}
//      didAdded = true
//        let grid = Grid(anchor: a)
//        self.grids.append(grid)
//        node.addChildNode(grid)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
//        let grid = self.grids.filter { grid in
//            return grid.anchor.identifier == planeAnchor.identifier
//            }.first
//
//        guard let foundGrid = grid else {
//            return
//        }
//
//        foundGrid.update(anchor: planeAnchor)
    }
}
