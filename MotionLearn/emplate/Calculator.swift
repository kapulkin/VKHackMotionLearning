//
//  Calculator.swift
//  MotionLearn
//
//  Created by Amahstla . on 28/09/2019.
//  Copyright © 2019 VK. All rights reserved.
//

import UIKit

extension UIImage {
  
  func sizeToFitScreen() -> CGSize {
    
    let screenSize = UIScreen.main.bounds.size
    let imgSize = self.size
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
    
    return size
  }

    func sizeToFitVideo() -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        var imgSize = self.size
//        if (imgSize.width > imgSize.height) {
//            imgSize = CGSize(width: imgSize.height, height: imgSize.width)
//        }
        var size = CGSize(width: 0.125, height: 0.125)
        let screenRatio = screenSize.height / screenSize.width
        let imgRatio = imgSize.height / imgSize.width
        if (screenRatio > imgRatio) {
          size = CGSize(width: size.width, height: size.height * imgRatio)
        } else {
          size = CGSize(width: size.width / imgRatio, height: size.height)
        }
        
        return size
    }
}
