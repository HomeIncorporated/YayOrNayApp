//
//  UIColor.swift
//  YayOrNay
//
//  Created by Ilay on 01/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

extension UIColor {
    static let appPink = UIColor(hexString: "#AD5389")
    static let appPurple = UIColor(hexString: "#8E2DE2")
    static let appOrange = UIColor(hexString: "#FF5E5B")
    static let appWhite = UIColor(hexString: "#F2F7F2")
    static let appBlack = UIColor(hexString: "#080708")
    static let appTurquoise = UIColor(hexString: "#48A9A6")

    static let appOrangeAccent = UIColor(hexString: "#FF8987")
    static let appOrangeDarker = UIColor(hexString: "#BA4543")
    static let appWhiteAccent = UIColor(hexString: "#DFE3DF")
    static let appLightBlack = UIColor(hexString: "#3A3939")
}
