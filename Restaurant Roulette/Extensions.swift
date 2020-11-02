//
//  Extensions.swift
//  Restaurant Roulette
//
//  Created by Jared Cassoutt on 10/26/20.
//

import Foundation
import UIKit

extension UILabel {
    //animates UILabel to type out text
    func typewriterAnimation(characterDelay: TimeInterval = 5.0) {
        let typedText = text!
        text = ""
        var write: DispatchWorkItem?
        write = DispatchWorkItem { [weak weakSelf = self] in
            for letter in typedText {
                DispatchQueue.main.async {
                    weakSelf?.text!.append(letter)
                }
                Thread.sleep(forTimeInterval: characterDelay/100)
            }
        }
        if let task = write {
            let queue = DispatchQueue(label: "writetime", qos: DispatchQoS.userInteractive)
            queue.asyncAfter(deadline: .now() + 0.05, execute: task)
        }
    }
}

extension UIView {
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity

        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
}

//MARK:- IBInspectable
extension UIView {
    //allows for shadow features to be edited in Xcode attributes inspector
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.masksToBounds = false
            layer.shadowRadius = newValue
        }
    }
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.masksToBounds = false
            layer.shadowOpacity = newValue
        }
    }
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.masksToBounds = false
            layer.shadowOffset = newValue
        }
    }
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}
