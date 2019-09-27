/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's main view controller.
*/

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var arView: ARSCNView!
    @IBOutlet var messageLabel: RoundedLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let vase = try ModelEntity.load(named: "vase")
            
            // Place model on a horizontal plane.
//            let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.15, 0.15])
//            arView.scene.anchors.append(anchor)
          arView.delegate = self
            vase.scale = [1, 1, 1] * 0.006
//            anchor.children.append(vase)
        } catch {
            fatalError("Failed to load asset.")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.togglePeopleOcclusion()
      config.planeDetection = .vertical
      
    }

    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        togglePeopleOcclusion()
    }
    
  var config: ARWorldTrackingConfiguration!
  
    fileprivate func togglePeopleOcclusion() {
        guard let config = arView.session.configuration as? ARWorldTrackingConfiguration,
            ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentation) else {
                fatalError("People occlusion is not supported on this device.")
        }
      
      self.config = config
      
      switch config.frameSemantics {
        case [.personSegmentation]:
            config.frameSemantics.remove(.personSegmentation)
            messageLabel.displayMessage("People occlusion off", duration: 1.0)
        default:
            config.frameSemantics.insert(.personSegmentation)
            messageLabel.displayMessage("People occlusion on", duration: 1.0)
        }

        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
}
extension ViewController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
  //1. Check We Have Detected An ARPlaneAnchor
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

    //2. Get The Size Of The ARPlaneAnchor
    let width = CGFloat(planeAnchor.extent.x)
    let height = CGFloat(planeAnchor.extent.z)

    //3. Create An SCNPlane Which Matches The Size Of The ARPlaneAnchor
    let imageHolder = SCNNode(geometry: SCNPlane(width: width, height: height))

    //4. Rotate It
    imageHolder.eulerAngles.x = -.pi/2

    //5. Set It's Colour To Red
    imageHolder.geometry?.firstMaterial?.diffuse.contents = UIColor.red

    //4. Add It To Our Node & Thus The Hiearchy
    node.addChildNode(imageHolder)
  }
}

