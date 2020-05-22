//
//  UITextfield.swift
//  YayOrNay
//
//  Created by Ilay on 02/10/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit

extension UITextField {
    
    //Simply creating a UIView that has width of points chosen, and adding it to the right/left of the UITextfield so we have the padding effect.
    func setLeftPadding(with points: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: points, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPadding(with points: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: points, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
