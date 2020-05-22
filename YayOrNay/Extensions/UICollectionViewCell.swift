//
//  UICollectionViewCell.swift
//  YayOrNay
//
//  Created by Ilay on 03/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit
extension UICollectionViewCell {
    func setCornerAndShadow(){
        let radius: CGFloat = 10

        self.contentView.layer.cornerRadius = radius
        // Always mask the inside view
        self.contentView.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 0.3
        // Never mask the shadow as it falls outside the view
        self.layer.masksToBounds = false

        // Matching the contentView radius here will keep the shadow
        // in sync with the contentView's rounded shape
        self.layer.cornerRadius = radius
    }
}
