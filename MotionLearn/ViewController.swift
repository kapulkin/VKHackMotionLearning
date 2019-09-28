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

class ViewController:
  UIViewController,
  ARSCNViewDelegate,
  RecordButtonDelegate,
  RPScreenRecorderDelegate,
  RPPreviewViewControllerDelegate,
  ARSessionDelegate {
  
  //MARK: - Outlets
  
  @IBOutlet private var button: RecordButton!
  @IBOutlet private var sceneView: ARSCNView!
  
  //MARK: - Properties
  
  var recorder = RPScreenRecorder.shared()
  var img: UIImage?
  var videoURL: URL?
  
  //MARK: - Memory
  
  override func viewDidLoad() {
    super.viewDidLoad()
    button.delegate = self
    recorder.delegate = self
    configureSCNView()
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
  
  //MARK: - Actions
  
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
  
  @objc
  func playerItemDidReachEnd(notification: NSNotification) {
    if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
      playerItem.seek(to: kCMTimeZero)
    }
  }
  
  // MARK: - ARSCNViewDelegate
  
  func sessionWasInterrupted(_ session: ARSession) {
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
  }
  
  //MARK: - RecordButtonDelegate
  
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
  
  //MARK: - RPPreviewViewControllerDelegate
  
  func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
    previewController.dismiss(animated: true, completion: nil)
  }
  
  //MARK: - Private
  
  func configureSCNView() {
    let configuration = ARWorldTrackingConfiguration()
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
    let size = img?.sizeToFitScreen() ?? CGSize(width: 1, height: 1)
    let ball = SCNPlane(width: size.width, height: size.height)
    
    let ballNode = SCNNode(geometry: ball)
    
    ballNode.position = SCNVector3Make(0, 0, -0.2)
    
    
    let spriteKitScene = SKScene(size: CGSize(width: sceneView.frame.width, height: sceneView.frame.height))
    spriteKitScene.scaleMode = .aspectFit
    
    // Create a video player, which will be responsible for the playback of the video material
    let videoUrl = Bundle.main.url(forResource: "video", withExtension: "mp4")!
    let videoPlayer = AVPlayer(url: self.videoURL ?? videoUrl)
    
    // To make the video loop
    videoPlayer.actionAtItemEnd = .none
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(ViewController.playerItemDidReachEnd),
      name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
      object: videoPlayer.currentItem)
    
    // Create the SpriteKit video node, containing the video player
    let videoSpriteKitNode = SKVideoNode(avPlayer: videoPlayer)
    videoSpriteKitNode.position = CGPoint(x: spriteKitScene.size.width / 2.0,
                                          y: spriteKitScene.size.height / 2.0)
    videoSpriteKitNode.size = spriteKitScene.size
    videoSpriteKitNode.yScale = -1.0
    videoSpriteKitNode.play()
    spriteKitScene.addChild(videoSpriteKitNode)
    // Create the SceneKit scene
    if let img = img {
      ballNode.geometry?.firstMaterial?.diffuse.contents = img
    }else {
      ballNode.geometry?.firstMaterial?.diffuse.contents = videoPlayer

    }
    
    sceneView.pointOfView?.addChildNode(ballNode)
    sceneView.session.delegate = self
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      videoPlayer.play()
    }
  }
  
  //MARK: - ARSessionDelegate
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    ARScreenRecorder.shared.render(frame: frame)
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    guard error is ARError else { return }
    
    let errorWithInfo = error as NSError
    let messages = [
      errorWithInfo.localizedDescription,
      errorWithInfo.localizedFailureReason,
      errorWithInfo.localizedRecoverySuggestion
    ]
    
    // Use `flatMap(_:)` to remove optional error messages.
    let errorMessage = messages.flatMap({ $0 }).joined(separator: "\n")
    print(errorMessage,  "errormessage")
  }
}
