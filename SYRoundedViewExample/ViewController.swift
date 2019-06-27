//
//  ViewController.swift
//  SYRoundedViewExample
//
//  Created by Stanislas Chevallier on 27/06/2019.
//  Copyright © 2019 Syan.me. All rights reserved.
//

import UIKit
import SYRoundedView

class ViewController: UIViewController {
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        roundedView.backgroundColor = .lightGray
        roundedView.maskedCorners   = []
        roundedView.drawnCorners    = []
        roundedView.drawnBorders    = []
        roundedView.borderWidth     = 2
        roundedView.borderColor     = .red
        roundedView.cornerRadius    = 30
        view.addSubview(roundedView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateStyle()
        // applyStaticStyle()
    }
    
    // MARK: Properties
    private let roundedView = SYRoundedView()
    
    // MARK: Examples
    private func applyStaticStyle() {
        roundedView.borderWidth     = 10
        roundedView.borderColor     = .red
        roundedView.cornerRadius    = 30
        roundedView.drawnBorders    = .all
        roundedView.drawnCorners    = [.bottomLeft, .topLeft]
        roundedView.maskedCorners   = [.bottomLeft, .topLeft]
        roundedView.frame           = view.bounds.insetBy(dx: 30, dy: 30)
        
        roundedView.animateStroke(from: 0, to: 1, duration: 2, animateStrokeStart: true, reverse: false, maxRepeat: 2, removePreviousAnimation: true)
    }
    
    private func animateStyle() {
        var frame = view.bounds.insetBy(dx: 40, dy: 40)
        
        frame.origin.x += CGFloat(arc4random() % 50)
        frame.origin.y += CGFloat(arc4random() % 50)
        frame.size.width  -= CGFloat(arc4random() % 100)
        frame.size.height -= CGFloat(arc4random() % 100)
        
        var corners: UIRectCorner = []
        if (arc4random() % 2 == 1) { corners.insert(.topLeft) }
        if (arc4random() % 2 == 1) { corners.insert(.topRight) }
        if (arc4random() % 2 == 1) { corners.insert(.bottomLeft) }
        if (arc4random() % 2 == 1) { corners.insert(.bottomRight) }
        
        var borders: UIRectEdge = []
        if (arc4random() % 2 == 1) { borders.insert(.top) }
        if (arc4random() % 2 == 1) { borders.insert(.left) }
        if (arc4random() % 2 == 1) { borders.insert(.right) }
        if (arc4random() % 2 == 1) { borders.insert(.bottom) }
        
        roundedView.animate(duration: 1, curve: .easeInOut, animations: {
            self.roundedView.borderWidth    = CGFloat(arc4random() % 30)
            self.roundedView.borderColor    = arc4random() % 2 == 1 ? .red : .blue
            self.roundedView.cornerRadius   = CGFloat(arc4random() % 30)
            self.roundedView.drawnBorders   = .all
            self.roundedView.drawnCorners   = corners
            self.roundedView.maskedCorners  = corners
            self.roundedView.frame          = frame
            self.roundedView.layoutIfNeeded()
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.animateStyle()
        }
    }
}
