//
//  UINavigationControllerExt.swift
//  InstagramClone
//
//  Created by Lova Krishna on 25/04/20.
//  Copyright © 2020 Lova Krishna. All rights reserved.
//

import UIKit

extension UINavigationController {
    func makeNavigationBarTransparent() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }
}


