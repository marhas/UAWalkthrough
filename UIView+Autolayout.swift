//
//  UIView+Autolayout.swift
//  UAWalkthrough
//
//  Created by Marcel Hasselaar on 2019-10-15.
//  Copyright © 2019 Marcel Hasselaar. All rights reserved.

import UIKit

extension UIView {

    func verticallyBound(inside other: UIView, topInset: CGFloat = 0, bottomInset: CGFloat = 0, considerSafeArea: Bool = true) {
        translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *), considerSafeArea {
            topAnchor.constraint(equalTo: other.safeAreaLayoutGuide.topAnchor, constant: topInset).isActive = true
        } else {
            topAnchor.constraint(equalTo: other.topAnchor, constant: topInset).isActive = true
        }

        if #available(iOS 11.0, *), considerSafeArea {
            bottomAnchor.constraint(equalTo: other.safeAreaLayoutGuide.bottomAnchor, constant: -bottomInset).isActive = true
        } else {
            bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -bottomInset).isActive = true
        }
    }

    func horizontallyBound(inside other: UIView, leftInset: CGFloat = 0, rightInset: CGFloat = 0, considerSafeArea: Bool = true) {
        translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *), considerSafeArea {
            leftAnchor.constraint(equalTo: other.safeAreaLayoutGuide.leftAnchor, constant: leftInset).isActive = true
        } else {
            leftAnchor.constraint(equalTo: other.leftAnchor, constant: leftInset).isActive = true
        }

        if #available(iOS 11.0, *), considerSafeArea {
            rightAnchor.constraint(equalTo: other.safeAreaLayoutGuide.rightAnchor, constant: -rightInset).isActive = true
        } else {
            rightAnchor.constraint(equalTo: other.rightAnchor, constant: -rightInset).isActive = true
        }
    }

    func horizontallyCentered(in other: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: other.centerXAnchor).isActive = true
    }

    func verticallyCentered(in other: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: other.centerYAnchor).isActive = true
    }

    func centered(in other: UIView) {
        verticallyCentered(in: other)
        horizontallyCentered(in: other)
    }

    func bound(inside other: UIView, withInsets insets: UIEdgeInsets = UIEdgeInsets.zero, considerSafeArea: Bool = true) {
        verticallyBound(inside: other, topInset: insets.top, bottomInset: insets.bottom, considerSafeArea: considerSafeArea)
        horizontallyBound(inside: other, leftInset: insets.left, rightInset: insets.right, considerSafeArea: considerSafeArea)
    }

    func sizedTo(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
