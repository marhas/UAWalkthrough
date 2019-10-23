//
//  UIColor+utils.swift
//  UAWalkthrough
//
//  Created by Marcel Hasselaar on 2018-02-13.
//  Copyright © 2018 Marcel Hasselaar. All rights reserved.

import UIKit

extension UIColor {
    convenience init(hex string: String) {
        var hex = string.hasPrefix("#")
            ? String(string.dropFirst())
            : string
        guard hex.count == 3 || hex.count == 6
            else {
                self.init(white: 1.0, alpha: 0.0)
                return
        }
        if hex.count == 3 {
            for (index, char) in hex.enumerated() {
                hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
            }
        }

        self.init(
            red:   CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF) / 255.0,
            green: CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF) / 255.0,
            blue:  CGFloat((Int(hex, radix: 16)!) & 0xFF) / 255.0, alpha: 1.0)
    }

    static var tooltipBackground: UIColor {
        return UIColor(hex: "BED2E5")
    }

    static var tooltipText: UIColor {
        return UIColor(hex: "2E2E2D")
    }
}
