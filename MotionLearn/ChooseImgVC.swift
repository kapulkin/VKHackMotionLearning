//
//  ChooseImgVC.swift
//  MotionLearn
//
//  Created by Amahstla . on 28/09/2019.
//  Copyright © 2019 VK. All rights reserved.
//

import UIKit
import MobileCoreServices
import ARKit

class ChooseImgVC: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard #available(iOS 13, *) else {return}
    
    
    AttachmentHandler.shared.imagePickedBlock = { (image) in
      /* get your image here */
      
      if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ViewController") as? ViewController {
        vc.img = image
        Router.switchRootVC(to: vc)
      }
    }
    AttachmentHandler.shared.videoPickedBlock = {(url) in
      if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ViewController") as? ViewController {
        vc.videoURL = url as URL
        Router.switchRootVC(to: vc)
      }
      /* get your compressed video url here */
    }
    

  }
  
  var isAppeared = false
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard ARWorldTrackingConfiguration.supportsFrameSemantics(ARConfiguration.FrameSemantics.personSegmentationWithDepth)
        else {
            openBlockVC()
            return
    }
    guard !isAppeared else {return}
    isAppeared.toggle()
    AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
  }
    
    
      private func openBlockVC() {
             guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "BlockVC") as? BlockVC else {
                 return
             }
             UIApplication.shared.keyWindow?.rootViewController = vc
         }
}
extension ChooseImgVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    if #available(iOS 13.0, *) {
      picker.dismiss(animated: true) { [weak self] in
        guard let self = self else {return}
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ViewController") as? ViewController,
          let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
          vc.img = img
          Router.switchRootVC(to: vc)
        }
      }
    } else {
      // Fallback on earlier versions
    }
  }
}
protocol RecordButtonDelegate: class {
  
  func tapButton(isRecording: Bool)
}

@IBDesignable open class RecordButton: UIView {
  
  private var isRecording = false
  private var roundView: UIView?
  private var squareSide: CGFloat?
  
  private let externalCircleFactor: CGFloat = 0.1
  private let roundViewSideFactor: CGFloat = 0.8
  
  weak var delegate: RecordButtonDelegate?
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.clear
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.backgroundColor = UIColor.clear
  }
  
  override open func draw(_ rect: CGRect) {
    
    setupRecordButtonView()
  }
  
  private func setupRecordButtonView() {
    
    drawExternalCircle()
    drawRoundedButton()
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedView(_:))))
    
  }
  private func drawExternalCircle() {
    
    let layer = CAShapeLayer()
    let radius = min(self.bounds.width, self.bounds.height)/2
    let lineWidth = externalCircleFactor*radius
    layer.path = UIBezierPath(arcCenter: CGPoint(x: self.bounds.size.width/2,
                                                 y: self.bounds.size.height/2),
                              radius: radius-lineWidth/2,
                              startAngle: 0,
                              endAngle: 2*CGFloat(Float.pi),
                              clockwise: true).cgPath
    layer.lineWidth = lineWidth
    layer.fillColor = UIColor.clear.cgColor
    layer.strokeColor = UIColor.white.cgColor
    layer.opacity = 1
    
    self.layer.addSublayer(layer)
  }
  
  private func drawRoundedButton() {
    
    squareSide = roundViewSideFactor*min(self.bounds.width, self.bounds.height)
    
    roundView = UIView(frame: CGRect(x: self.frame.size.width/2-squareSide!/2,
                                     y: self.frame.size.height/2-squareSide!/2,
                                     width: squareSide!,
                                     height: squareSide!))
    roundView?.backgroundColor = UIColor.red
    roundView?.layer.cornerRadius = squareSide!/2
    
    self.addSubview(roundView!)
  }
  private func recordButtonAnimation() -> CAAnimationGroup {
    
    let transformToStopButton = CABasicAnimation(keyPath: "cornerRadius")
    
    transformToStopButton.fromValue = !isRecording ? squareSide!/2: 10
    transformToStopButton.toValue = !isRecording ? 10:squareSide!/2
    
    let toSmallCircle = CABasicAnimation(keyPath: "transform.scale")
    
    toSmallCircle.fromValue = !isRecording ? 1: 0.65
    toSmallCircle.toValue = !isRecording ? 0.65: 1
    
    let animationGroup = CAAnimationGroup()
    animationGroup.animations = [transformToStopButton, toSmallCircle]
    animationGroup.duration = 0.25
    animationGroup.fillMode = kCAFillModeBoth
    animationGroup.isRemovedOnCompletion = false
    
    return animationGroup
    
  }
  
  @objc func tappedView(_ sender: UITapGestureRecognizer) {
    
    self.roundView?.layer.add(self.recordButtonAnimation(), forKey: "")
    
    isRecording = !isRecording
    delegate?.tapButton(isRecording: isRecording)
    
  }

  override open func prepareForInterfaceBuilder() {
    self.backgroundColor = UIColor.clear
    setupRecordButtonView()
  }
  
}
