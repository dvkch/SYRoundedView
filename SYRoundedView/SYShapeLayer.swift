//
//  SYShapeLayer.swift
//  SYRoundedView
//
//  Created by Stanislas Chevallier on 27/06/2019.
//

import UIKit

internal class SYShapeLayer: CAShapeLayer {
    
    // MARK: Properties
    internal var currentPath: CGPath? {
        didSet {
            previousPath = oldValue
            path = currentPath
        }
    }
    private var previousPath: CGPath?
    
    internal var currentLineWidth: CGFloat = 0 {
        didSet {
            previousLineWidth = oldValue
            lineWidth = currentLineWidth
        }
    }
    private var previousLineWidth: CGFloat = 0
    
    internal var currentStrokeColor: CGColor? {
        didSet {
            previousStrokeColor = oldValue
            strokeColor = currentStrokeColor
        }
    }
    private var previousStrokeColor: CGColor?

    // MARK: Layer actions
    override func action(forKey event: String) -> CAAction? {
        switch event {
        case "path":
            let anim = CABasicAnimation(keyPath: event)
            anim.fromValue = previousPath
            anim.toValue   = currentPath
            return anim
            
        case "lineWidth":
            let anim = CABasicAnimation(keyPath: event)
            anim.fromValue = previousLineWidth
            anim.toValue   = currentLineWidth
            return anim
            
        case "strokeColor":
            let anim = CABasicAnimation(keyPath: event)
            anim.fromValue = previousStrokeColor
            anim.toValue   = currentStrokeColor
            return anim
            
        default:
            return super.action(forKey: event)
        }
    }
}

