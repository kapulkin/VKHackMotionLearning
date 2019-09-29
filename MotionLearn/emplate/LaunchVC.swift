//
//  LaunchVC.swift
//  MotionLearn
//
//  Created by Amahstla . on 29/09/2019.
//  Copyright © 2019 VK. All rights reserved.
//

import UIKit

class LaunchVC: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    Timer(timeInterval: 1, target: self, selector: #selector(showMain), userInfo: nil, repeats: false).fire()
  }
  
  @objc func showMain() {
    
    if #available(iOS 13.0, *) {
      if let vc: ChooseImgVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ChooseImgVC") as? ChooseImgVC {
        Router.switchRootVC(to: vc)
      }
    } else {
      // Fallback on earlier versions
    }
  }
}
