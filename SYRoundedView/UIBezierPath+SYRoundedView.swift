//
//  SYRoundedView.swift
//  Pods-SYKitExample
//
//  Created by Stanislas Chevallier on 27/06/2019.
//

import UIKit

internal extension UIBezierPath {
    
    func moveIfNeeded(to point: CGPoint) {
        guard abs(self.currentPoint.x - point.x) > 2 * .leastNormalMagnitude || abs(self.currentPoint.y - point.y) > 2 * .leastNormalMagnitude else {
            return
        }
        move(to: point)
    }
    
    func addClockwiseCorner(_ corner: UIRectCorner, from: CGPoint, to: CGPoint) {
        let controlPoint1: CGPoint
        let controlPoint2: CGPoint
        
        switch corner {
        case .bottomLeft, .topRight:
            controlPoint1 = CGPoint(x: from.x + (to.x - from.x) * 0.555, y: from.y)
            controlPoint2 = CGPoint(x: to.x, y: to.y + (from.y - to.y) * 0.555)
            break;
        case .bottomRight, .topLeft:
            controlPoint1 = CGPoint(x: from.x, y: from.y + (to.y - from.y) * 0.555);
            controlPoint2 = CGPoint(x: to.x + (from.x - to.x) * 0.555, y: to.y);
            break;
        default:
            controlPoint1 = from
            controlPoint2 = to
            break;
        }
        
        moveIfNeeded(to: from)
        addCurve(to: to, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
}

