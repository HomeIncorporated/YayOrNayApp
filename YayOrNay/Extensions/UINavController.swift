//
//  UINavigationBar.swift
//  YayOrNay
//
//  Created by Ilay on 03/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController{
    func setNavBar(){
        self.navigationBar.barStyle = .black
        self.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.appWhite]
        self.navigationBar.tintColor = UIColor.appWhite
        self.navigationBar.prefersLargeTitles = true
    }
}

