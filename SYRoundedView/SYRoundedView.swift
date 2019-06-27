//
//  SYRoundedView.swift
//  Pods-SYKitExample
//
//  Created by Stanislas Chevallier on 27/06/2019.
//

import UIKit

// LATER: fillLayer + strokeLayer instead of mask, to allow shadows
@objcMembers
public class SYRoundedView : UIView {
    
    // MARK: Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        maskLayer.frame = shapeLayer.bounds
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        
        shapeLayer.lineWidth = 1
        shapeLayer.strokeColor = tintColor?.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor

        if SYRoundedView.enableMaskDebug {
            shapeLayer.addSublayer(maskLayer)
        }
    }
    
    // MARK: Public properties
    public static var enableMaskDebug: Bool = false
    
    @IBInspectable public var drawnCorners: UIRectCorner = .allCorners {
        didSet {
            guard drawnCorners != oldValue, !inhibitAutoPathUpdates else { return }
            updateDrawnPath()
        }
    }
    @IBInspectable public var drawnBorders: UIRectEdge = .all {
        didSet {
            guard drawnBorders != oldValue, !inhibitAutoPathUpdates else { return }
            updateDrawnPath()
        }
    }
    @IBInspectable public var maskedCorners: UIRectCorner = .allCorners {
        didSet {
            guard maskedCorners != oldValue else { return }

            if SYRoundedView.enableMaskDebug {
                shapeLayer.addSublayer(maskLayer)
            }
            else {
                if maskedCorners == [], shapeLayer.mask != nil {
                    shapeLayer.mask = nil
                }
                
                if maskedCorners != [], shapeLayer.mask == nil {
                    shapeLayer.mask = maskLayer
                }
            }
            
            if !inhibitAutoPathUpdates {
                updateMaskPath()
            }
        }
    }
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            guard cornerRadius != oldValue, !inhibitAutoPathUpdates else { return }
            updateMaskPath()
            updateDrawnPath()
        }
    }
    @IBInspectable public var borderColor: UIColor? {
        didSet {
            guard borderColor != oldValue else { return }
            shapeLayer.strokeColor = borderColor?.cgColor
        }
    }
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            guard borderWidth != oldValue else { return }
            maskLayer.currentLineWidth = borderWidth
            shapeLayer.currentLineWidth = borderWidth
        }
    }
    @IBInspectable public var animatePaths: Bool = false
    
    // MARK: Private properties
    private var shapeLayer: SYShapeLayer {
        return layer as! SYShapeLayer
    }
    private let maskLayer = SYShapeLayer()
    private var inhibitAutoPathUpdates: Bool = false
    
    public override class var layerClass: AnyClass {
        return SYShapeLayer.self
    }
    
    // MARK: Layout
    private var previousBounds = CGRect.zero
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if previousBounds != bounds {
            previousBounds = bounds
            
            maskLayer.position = superview?.convert(center, to: self) ?? .zero
            maskLayer.bounds = shapeLayer.bounds
            
            if !inhibitAutoPathUpdates {
                updateMaskPath()
                updateDrawnPath()
            }
        }
    }
    
    // MARK: Public getters
    public var maskPath: UIBezierPath? {
        return createBezierPath(corners: maskedCorners, borders: .all, closePath: true)
    }
    
    public var drawnPath: UIBezierPath? {
        return createBezierPath(corners: drawnCorners, borders: drawnBorders, closePath: false)
    }

    // MARK: Public methods
    public func animate(duration: TimeInterval, curve: UIView.AnimationCurve, animations: (() -> ())?, completion: (() -> ())?) {
        let timing: CAMediaTimingFunctionName
        let option: UIView.AnimationOptions
        
        switch curve {
        case .easeIn:
            timing = .easeIn
            option = .curveEaseIn

        case .easeInOut:
            timing = .easeInEaseOut
            option = .curveEaseInOut

        case .easeOut:
            timing = .easeOut
            option = .curveEaseOut
            
        default:
            timing = .linear
            option = .curveLinear
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: option, animations: {
            CATransaction.begin()
            CATransaction.setAnimationDuration(duration)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: timing))
            self.applyChangesInASingleCommit(animations)
            CATransaction.commit()
        }, completion: { _ in
            completion?()
        })
    }
    
    public func applyChangesInASingleCommit(_ changes: (() -> ())?) {
        inhibitAutoPathUpdates = true
        changes?()
        updateDrawnPath()
        updateMaskPath()
        inhibitAutoPathUpdates = false
    }
    
    public func animateStroke(from: CGFloat, to: CGFloat, duration: TimeInterval, animateStrokeStart: Bool, reverse: Bool, maxRepeat: Int, removePreviousAnimation: Bool) {
        let keyPath = animateStrokeStart ? "strokeStart" : "strokeEnd"
        let animationName = "SYRoundedView-" + keyPath
        
        if removePreviousAnimation {
            shapeLayer.removeAnimation(forKey: animationName)
        }
        
        let anim = CABasicAnimation(keyPath: keyPath)
        anim.fromValue      = from
        anim.toValue        = to
        anim.duration       = duration
        anim.repeatCount    = .greatestFiniteMagnitude
        anim.repeatDuration = TimeInterval(maxRepeat) * duration
        anim.autoreverses   = reverse
        shapeLayer.add(anim, forKey: animationName)
    }
    
    // MARK: Private methods
    private func updateMaskPath() {
        maskLayer.currentPath = createBezierPath(corners: maskedCorners, borders: .all, closePath: true).cgPath
    }
    
    private func updateDrawnPath() {
        shapeLayer.currentPath = createBezierPath(corners: drawnCorners, borders: drawnBorders, closePath: false).cgPath
    }
    
    private func createBezierPath(corners: UIRectCorner, borders: UIRectEdge, closePath: Bool) -> UIBezierPath {
        let radiusTopLeft     = corners.contains(.topLeft)     ? cornerRadius : CGFloat.leastNormalMagnitude
        let radiusTopRight    = corners.contains(.topRight)    ? cornerRadius : CGFloat.leastNormalMagnitude
        let radiusBottomLeft  = corners.contains(.bottomLeft)  ? cornerRadius : CGFloat.leastNormalMagnitude
        let radiusBottomRight = corners.contains(.bottomRight) ? cornerRadius : CGFloat.leastNormalMagnitude
        
        var pointT1 = CGPoint(x: bounds.minX, y: bounds.minY)
        let pointTM = CGPoint(x: bounds.midX, y: bounds.minY)
        var pointT2 = CGPoint(x: bounds.maxX, y: bounds.minY)
        var pointB1 = CGPoint(x: bounds.minX, y: bounds.maxY)
        var pointB2 = CGPoint(x: bounds.maxX, y: bounds.maxY)
        var pointL1 = pointT1
        var pointL2 = pointB1
        var pointR1 = pointT2
        var pointR2 = pointB2
        
        pointT1.x += radiusTopLeft
        pointL1.y += radiusTopLeft
        
        pointT2.x -= radiusTopRight
        pointR1.y += radiusTopRight
        
        pointB1.x += radiusBottomLeft
        pointL2.y -= radiusBottomLeft
        
        pointB2.x -= radiusBottomRight
        pointR2.y -= radiusBottomRight
        
        let path = UIBezierPath()
        path.move(to: pointTM)
        
        if borders.contains(.top) {
            path.move(to: pointTM)
            path.addLine(to: pointT2)
        }
        
        // addArc is ignored for small radii, making the number of segment and control points
        // different from a path to another, leading to weird animations
        path.addClockwiseCorner(.topRight, from: pointT2, to: pointR1)
        
        if borders.contains(.right) {
            path.moveIfNeeded(to: pointR1)
            path.addLine(to: pointR2)
        }
        
        path.addClockwiseCorner(.bottomRight, from: pointR2, to: pointB2)
        
        if borders.contains(.bottom) {
            path.moveIfNeeded(to: pointB2)
            path.addLine(to: pointB1)
        }
        
        path.addClockwiseCorner(.bottomLeft, from: pointB1, to: pointL2)
        
        if borders.contains(.left) {
            path.moveIfNeeded(to: pointL2)
            path.addLine(to: pointL1)
        }
        
        path.addClockwiseCorner(.topLeft, from: pointL1, to: pointT1)
        
        if borders.contains(.top) {
            path.moveIfNeeded(to: pointT1)
            path.addLine(to: pointTM)
        }
        
        if closePath {
            path.close()
        }
        
        return path
    }
}
