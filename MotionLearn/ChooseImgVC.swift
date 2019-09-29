//
//  ChooseImgVC.swift
//  MotionLearn
//
//  Created by Amahstla . on 28/09/2019.
//  Copyright © 2019 VK. All rights reserved.
//

import UIKit
import MobileCoreServices

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
    
//    var imagePicker = UIImagePickerController()
//
//    if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
//        print("Button capture")
//
//        imagePicker.delegate = self
//        imagePicker.sourceType = .savedPhotosAlbum
//        imagePicker.allowsEditing = false
//        imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
//        present(imagePicker, animated: true, completion: nil)
//    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
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
