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
  
  private func switchRootVC(to vc: UIViewController, withScale: Bool = true, animated: Bool = true) {
         
         let app: UIApplication = UIApplication.shared
         guard let delegate = app.delegate,
             let window = delegate.window! else {
                 return
         }
         guard window.rootViewController != nil else {
             window.rootViewController = vc
             return
         }
         
         let snapShot: UIView = window.snapshotView(afterScreenUpdates: true) ?? UIView()
        
         if animated {
             vc.view.addSubview(snapShot)
         }
         
         window.rootViewController?.dismiss(animated: false, completion: nil)
         window.rootViewController = vc
         
         if animated {
             UIView.animate(withDuration: 0.3, animations: {
                 snapShot.layer.opacity = 0
                 if withScale == true {
                     snapShot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
                 }
             }) { (_) in
                 snapShot.removeFromSuperview()
             }
         }
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
//          self.present(vc, animated: true, completion: nil)
          self.switchRootVC(to: vc)
        }
      }
    } else {
      // Fallback on earlier versions
    }
  }
}
