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
      
      recorder = RPScreenRecorder.shared()
      recorder.delegate = self
      
      // A SpriteKit scene to contain the SpriteKit video node
      let spriteKitScene = SKScene(size: CGSize(width: sceneView.frame.width, height: sceneView.frame.height))
      spriteKitScene.scaleMode = .aspectFit

      // Create a video player, which will be responsible for the playback of the video material
      let videoUrl = Bundle.main.url(forResource: "video", withExtension: "mp4")!
      let videoPlayer = AVPlayer(url: videoUrl)

      // To make the video loop
      videoPlayer.actionAtItemEnd = .none
      NotificationCenter.default.addObserver(
          self,
          selector: #selector(ViewController.playerItemDidReachEnd),
          name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
          object: videoPlayer.currentItem)

      // Create the SpriteKit video node, containing the video player
      let videoSpriteKitNode = SKVideoNode(avPlayer: videoPlayer)
      videoSpriteKitNode.position = CGPoint(x: spriteKitScene.size.width / 2.0, y: spriteKitScene.size.height / 2.0)
      videoSpriteKitNode.size = spriteKitScene.size
      videoSpriteKitNode.yScale = -1.0
      videoSpriteKitNode.play()
      spriteKitScene.addChild(videoSpriteKitNode)

      // Create the SceneKit scene
      sceneView.isPlaying = true
      ball.firstMaterial?.diffuse.contents = spriteKitScene
      sceneView.pointOfView?.addChildNode(ballNode)
    }
  
  @objc func playerItemDidReachEnd(notification: NSNotification) {
         if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
             playerItem.seek(to: kCMTimeZero)
         }
     }
  
  @objc func record() {
    
  }
  var isWriting: Bool = false
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
//    if isWriting {
//
//      self.recorder?.finishWriting().onSuccess { [weak self] url in
//        print("Recording Finished", url)
//        DispatchQueue.global(qos: .background).async {
//            if let urlData = NSData(contentsOf: url) {
//                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
//                let filePath="\(documentsPath)/tempFile.mp4"
//                DispatchQueue.main.async {
//                    urlData.write(toFile: filePath, atomically: true)
//                    PHPhotoLibrary.shared().performChanges({
//                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
//                    }) { completed, error in
//                        if completed {
//                            print("Video is saved!")
//                        }
//                    }
//                }
//            }
//        }
//
//      }
//
//    }else {
//      self.recorder?.startWriting().onSuccess {
//             print("Recording Started")
//           }
//    }
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

extension ViewController: RPPreviewViewControllerDelegate {
  func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
    previewController.dismiss(animated: true, completion: nil)
  }
}
