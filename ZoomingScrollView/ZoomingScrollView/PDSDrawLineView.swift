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
    //http://stackoverflow.com/questions/8702696/drawing-smooth-curves-methods-needed
    //https://code.tutsplus.com/tutorials/smooth-freehand-drawing-on-ios--mobile-13164
    
    func addCurveToConnect(pointList : [CGPoint]) {
        
        let path = UIBezierPath()
        
        var pLast : CGPoint? = nil
        
        for (index, point) in pointList.enumerated() {
            if index == 0 {
                path.move(to: point)
            }
            else {
                let midPoint = self.midPointForPoints(pLast!, point)
                path.addQuadCurve(to: midPoint, controlPoint: self.controlPointForPoints(midPoint, pLast!))
                path.addQuadCurve(to: point,
                                  controlPoint: self.controlPointForPoints(midPoint, point))
            }
            pLast = point
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
    
    //MARK : - Curve2
    //https://medium.com/@ramshandilya/draw-smooth-curves-through-a-set-of-points-in-ios-34f6d73c8f9#.404ifx84w
    
    func addCurve2ToConnect(pointList : [CGPoint]) {
        let ptss = CubicCurveAlgorithm().controlPointsFromPoints(dataPoints: pointList)
        
        let path = UIBezierPath()
        path.lineWidth = 3
        for (index, point) in pointList.enumerated() {
            if index == 0 {
                path.move(to: point)
            }
            else {
                let pts = ptss[index - 1]
                path.addCurve(to: point,
                              controlPoint1: pts.controlPoint1,
                              controlPoint2: pts.controlPoint2)
            }
        }
        path.stroke()
    }
}

struct CubicCurveSegment
{
    let controlPoint1: CGPoint
    let controlPoint2: CGPoint
}

class CubicCurveAlgorithm
{
    private var firstControlPoints: [CGPoint?] = []
    private var secondControlPoints: [CGPoint?] = []
    
    func controlPointsFromPoints(dataPoints: [CGPoint]) -> [CubicCurveSegment] {
        
        //Number of Segments
        let count = dataPoints.count - 1
        
        //P0, P1, P2, P3 are the points for each segment, where P0 & P3 are the knots and P1, P2 are the control points.
        if count == 1 {
            let P0 = dataPoints[0]
            let P3 = dataPoints[1]
            
            //Calculate First Control Point
            //3P1 = 2P0 + P3
            
            let P1x = (2*P0.x + P3.x)/3
            let P1y = (2*P0.y + P3.y)/3
            
            firstControlPoints.append(CGPoint(x: P1x, y: P1y))
            
            //Calculate second Control Point
            //P2 = 2P1 - P0
            let P2x = (2*P1x - P0.x)
            let P2y = (2*P1y - P0.y)
            
            secondControlPoints.append(CGPoint(x: P2x, y: P2y))
        } else {
            firstControlPoints = Array(repeating: nil, count: count)
            
            var rhsArray = [CGPoint]()
            
            //Array of Coefficients
            var a = [Double]()
            var b = [Double]()
            var c = [Double]()
            
            for i in 0..<count {
                
                var rhsValueX: CGFloat = 0
                var rhsValueY: CGFloat = 0
                
                let P0 = dataPoints[i];
                let P3 = dataPoints[i+1];
                
                if i==0 {
                    a.append(0)
                    b.append(2)
                    c.append(1)
                    
                    //rhs for first segment
                    rhsValueX = P0.x + 2*P3.x;
                    rhsValueY = P0.y + 2*P3.y;
                    
                } else if i == count-1 {
                    a.append(2)
                    b.append(7)
                    c.append(0)
                    
                    //rhs for last segment
                    rhsValueX = 8*P0.x + P3.x;
                    rhsValueY = 8*P0.y + P3.y;
                } else {
                    a.append(1)
                    b.append(4)
                    c.append(1)
                    
                    rhsValueX = 4*P0.x + 2*P3.x;
                    rhsValueY = 4*P0.y + 2*P3.y;
                }
                
                rhsArray.append(CGPoint(x: rhsValueX, y: rhsValueY))
            }
            
            //Solve Ax=B. Use Tridiagonal matrix algorithm a.k.a Thomas Algorithm
            
            for i in 1..<count {
                let rhsValueX = rhsArray[i].x
                let rhsValueY = rhsArray[i].y
                
                let prevRhsValueX = rhsArray[i-1].x
                let prevRhsValueY = rhsArray[i-1].y
                
                let m = a[i]/b[i-1]
                
                let b1 = b[i] - m * c[i-1];
                b[i] = b1
                
                let r2x = rhsValueX.f - m * prevRhsValueX.f
                let r2y = rhsValueY.f - m * prevRhsValueY.f
                
                rhsArray[i] = CGPoint(x: r2x, y: r2y)
                
            }
            
            //Get First Control Points
            
            //Last control Point
            let lastControlPointX = rhsArray[count-1].x.f/b[count-1]
            let lastControlPointY = rhsArray[count-1].y.f/b[count-1]
            
            firstControlPoints[count-1] = CGPoint(x: lastControlPointX, y: lastControlPointY)
            
            for i in (0...count-2).reversed() {
                if let nextControlPoint = firstControlPoints[i+1] {
                    let controlPointX = (rhsArray[i].x.f - c[i] * nextControlPoint.x.f)/b[i]
                    let controlPointY = (rhsArray[i].y.f - c[i] * nextControlPoint.y.f)/b[i]
                    
                    firstControlPoints[i] = CGPoint(x: controlPointX, y: controlPointY)
                }
            }
            
            //Compute second Control Points from first
            for i in 0..<count {
                
                if i == count-1 {
                    let P3 = dataPoints[i+1]
                    
                    guard let P1 = firstControlPoints[i] else{
                        continue
                    }
                    
                    let controlPointX = (P3.x + P1.x)/2
                    let controlPointY = (P3.y + P1.y)/2
                    
                    secondControlPoints.append(CGPoint(x: controlPointX, y: controlPointY))
                    
                } else {
                    let P3 = dataPoints[i+1]
                    
                    guard let nextP1 = firstControlPoints[i+1] else {
                        continue
                    }
                    
                    let controlPointX = 2*P3.x - nextP1.x
                    let controlPointY = 2*P3.y - nextP1.y
                    
                    secondControlPoints.append(CGPoint(x: controlPointX, y: controlPointY))
                }
            }
        }
        
        var controlPoints = [CubicCurveSegment]()
        
        for i in 0..<count {
            if let firstControlPoint = firstControlPoints[i],
                let secondControlPoint = secondControlPoints[i] {
                let segment = CubicCurveSegment(controlPoint1: firstControlPoint, controlPoint2: secondControlPoint)
                controlPoints.append(segment)
            }
        }
        
        return controlPoints
    }
}

extension CGFloat {
    var f: Double {
        return Double(self)
    }
}
