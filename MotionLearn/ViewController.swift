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
import ReplayKit
//import PhotosUI
//import Photos

class ViewController: UIViewController, ARSCNViewDelegate, RecordButtonDelegate, RPScreenRecorderDelegate {
  
  @IBOutlet var button: RecordButton!
  @IBOutlet var sceneView: ARSCNView!
  var recorder: RPScreenRecorder!

    var img: UIImage! = UIImage(named: "mona-lisa")
  func tapButton(isRecording: Bool) {

    if !isRecording {
      recorder.stopRecording { (preview, error) in
          if let unwrappedPreview = preview {
              unwrappedPreview.previewControllerDelegate = self
              self.present(unwrappedPreview, animated: true)
          }
      }
        print("Start recording")
    } else {
        print("Stop recording")
      recorder.startRecording { error in
            if let unwrappedError = error {
                print(unwrappedError.localizedDescription)
            } else {
            }
        }
    }
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
//      iv.image = img
      button.delegate = self
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
        
      let screenSize = UIScreen.main.bounds.size
      let imgSize = img?.size ?? CGSize(width: 1, height: 1)
      var size = CGSize(width: 0.15, height: 0.15)
      let screenRatio = screenSize.height / screenSize.width
      let imgRatio = imgSize.height / imgSize.width
      if (screenRatio > imgRatio) {
        size = CGSize(width: size.width * screenRatio / imgRatio,
                      height: size.height * screenRatio / imgRatio)
      } else {
        size = CGSize(width: size.width * imgRatio / screenRatio,
                      height: size.height * imgRatio / screenRatio)
      }
      let ball = SCNPlane(width: size.width, height: size.height)
      
      let ballNode = SCNNode(geometry: ball)
      ballNode.geometry?.firstMaterial?.diffuse.contents = img
      ballNode.position = SCNVector3Make(0, 0, -0.2)
      sceneView.pointOfView?.addChildNode(ballNode)
      recorder = RPScreenRecorder.shared()
      recorder.delegate = self
    }
  
  @objc func record() {
    
  }
  
  @IBAction func onRecord(_ sender: UIButton) {
      let recorder = RPScreenRecorder.shared()

      if recorder.isRecording {
          sender.backgroundColor = .lightGray
    sender.titleLabel?.text = "Start record"
          recorder.stopRecording { (preview, error) in
              if let unwrappedPreview = preview {
                  unwrappedPreview.previewControllerDelegate = self
                  self.present(unwrappedPreview, animated: true)
              }
          }
      } else {
          recorder.startRecording { error in
              if let unwrappedError = error {
                  print(unwrappedError.localizedDescription)
              } else {
                  sender.backgroundColor = .red
        sender.titleLabel?.text = "Stop record"
                  print("record is started")
              }
          }
      }
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    }
}

extension ViewController: RPPreviewViewControllerDelegate {
  func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
    previewController.dismiss(animated: true, completion: nil)
  }
}
