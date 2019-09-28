//
//  Router.swift
//  MotionLearn
//
//  Created by Amahstla . on 28/09/2019.
//  Copyright © 2019 VK. All rights reserved.
//

import UIKit

class Router {
  static func switchRootVC(to vc: UIViewController, withScale: Bool = true, animated: Bool = true) {
         
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
