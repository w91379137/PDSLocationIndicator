//
//  DrawView.swift
//  ZoomingScrollView
//
//  Created by w91379137 on 2016/9/5.
//  Copyright © 2016年 w91379137. All rights reserved.
//

import UIKit

class PDSDrawLineView: UIView {
    
    var strokeColor : UIColor? = nil
    var lineWidth : CGFloat = 3
    var lineDash : (phase: CGFloat, lengths: [CGFloat])? = nil
    
    var pointListArray = [[CGPoint]]() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    //http://www.jianshu.com/p/d64b0abef349
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setLineWidth(self.lineWidth)
        if let color = self.strokeColor { context.setStrokeColor(color.cgColor) }
        if let lineDash = self.lineDash { context.setLineDash(phase: lineDash.phase, lengths: lineDash.lengths) }
        
        for pointList in self.pointListArray {
            context.addLineToConnect(pointList: pointList)
        }
    }
}

extension CGContext {
    
    //MARK : - Line
    func addLineToConnect(pointList : [CGPoint]) {
        
        for (index, point) in pointList.enumerated() {
            
            if index == 0 {
                self.move(to: point)
            }
            else {
                self.addLine(to: point)
            }
            
        }
        self.strokePath()
    }
    
    //MARK : - Curve
    //https://medium.com/@ramshandilya/draw-smooth-curves-through-a-set-of-points-in-ios-34f6d73c8f9#.404ifx84w
    func addCurveToConnect(pointList : [CGPoint]) {
        
        let path = UIBezierPath()
        var p1 : CGPoint? = nil
        
        for (index, point) in pointList.enumerated() {
            
            if index == 0 {
                path.move(to: point)
                p1 = point
            }
            else {
                self.addLine(to: point)
                
                let p2 = point
                let midPoint = self.midPointForPoints(p1!, point)
                path.addQuadCurve(to: midPoint, controlPoint: self.controlPointForPoints(midPoint, p1!))
                path.addQuadCurve(to: p2, controlPoint: self.controlPointForPoints(midPoint, p2))
                
                p1 = p2
            }
        }
        
        path.stroke()
    }
    
    func midPointForPoints(_ p1 : CGPoint, _ p2 : CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
    
    func controlPointForPoints(_ p1 : CGPoint,_  p2 : CGPoint) -> CGPoint {
        var controlPoint = midPointForPoints(p1, p2)
        let diffY = CGFloat( fabsf( Float(p2.y - controlPoint.y)))
        
        if p1.y < p2.y { controlPoint.y += diffY }
        else if p1.y > p2.y { controlPoint.y -= diffY }
        return controlPoint
    }
}

