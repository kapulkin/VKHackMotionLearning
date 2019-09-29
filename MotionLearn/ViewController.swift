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
    recorder.isMicrophoneEnabled = true
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
  
    @objc func playerItemDidReachEnd(notification: NSNotification) {
      if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
          playerItem.seek(to: kCMTimeZero)
      }
  }
 
  @IBAction func backAction(_ sender: Any) {
    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? ChooseImgVC {
      Router.switchRootVC(to: vc)
    }
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
//    sceneView.showsStatistics = true
//    sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
    sceneView.debugOptions = []
    
    // Create a video player, which will be responsible for the playback of the video material
    let videoUrl = Bundle.main.url(forResource: "video", withExtension: "mp4")!
    let videoPlayer = AVPlayer(url: self.videoURL ?? videoUrl)
    videoPlayer.isMuted = true

    var size = CGSize(width: 0.15, height: 0.15)
    if let img = img {
        size = img.sizeToFitVideo()
    } else {
        guard let videoTrack = videoPlayer.currentItem?.asset.tracks(withMediaType: AVMediaType.video).first else {
            return
        }
        let videoSizeRaw = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
        let videoSize = CGSize(width: fabs(videoSizeRaw.width), height: fabs(videoSizeRaw.height))

        let screenSize = UIScreen.main.bounds.size
        let screenRatio = screenSize.height / screenSize.width
        let videoRatio = videoSize.height / videoSize.width
        if (screenRatio > videoRatio) {
          size = CGSize(width: size.width, height: size.height * videoRatio)
        } else {
          size = CGSize(width: size.width / videoRatio, height: size.height)
        }
        let scale = CGFloat(1.5)
        size = CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    // Create a new scene
    let scene = SCNScene()
    
    // Set the scene to the view
    sceneView.scene = scene
            
    // To make the video loop
    videoPlayer.actionAtItemEnd = .none
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(ViewController.playerItemDidReachEnd),
      name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
      object: videoPlayer.currentItem)

    let imagePlane = SCNPlane(width: size.width, height: size.height)
    let imagePlaneNode = SCNNode(geometry: imagePlane)
    imagePlaneNode.position = SCNVector3Make(0, 0, -0.2)
    imagePlaneNode.localRotate(by: SCNQuaternion(x: 0, y: 0, z: 0.7071, w: 0.7071))

    // Create the SceneKit scene
    if let img = img {
      imagePlaneNode.geometry?.firstMaterial?.diffuse.contents = img
    } else {
      imagePlaneNode.geometry?.firstMaterial?.diffuse.contents = videoPlayer

    }
    
    sceneView.pointOfView?.addChildNode(imagePlaneNode)
    
    let backPlane = SCNPlane(width: 1, height: 1)
    let backPlaneNode = SCNNode(geometry: backPlane)
    backPlaneNode.position = SCNVector3Make(0, 0, -0.3)
    backPlaneNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    sceneView.pointOfView?.addChildNode(backPlaneNode)
    
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
