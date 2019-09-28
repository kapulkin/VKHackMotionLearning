//
//  ChooseImgVC.swift
//  MotionLearn
//
//  Created by Amahstla . on 28/09/2019.
//  Copyright © 2019 VK. All rights reserved.
//

import UIKit

class ChooseImgVC: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    var imagePicker = UIImagePickerController()

    if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
        print("Button capture")

      imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false

        present(imagePicker, animated: true, completion: nil)
    }
  }
}
extension ChooseImgVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    if #available(iOS 13.0, *) {
      if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ViewController") as? ViewController,
        let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
        vc.img = img
        self.present(vc, animated: true, completion: nil)
      }
    } else {
      // Fallback on earlier versions
    }
  }
}
