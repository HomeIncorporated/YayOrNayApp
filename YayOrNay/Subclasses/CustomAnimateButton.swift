//
//  CustomAnimateButton.swift
//  YayOrNay
//
//  Created by Ilay on 25/10/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit

class CustomAnimateButton: UIButton {
    
    var accentColor: UIColor!
    var mainColor: UIColor!
    
    convenience init(_ mainColor: UIColor, _ accentColor: UIColor) {
        self.init()
        self.mainColor = mainColor
        self.accentColor = accentColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 2.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            
            self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.backgroundColor = self.accentColor
        }, completion: nil)
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 2.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.backgroundColor = self.mainColor

        }, completion: nil)
        super.touchesEnded(touches, with: event)
    }
    
}
