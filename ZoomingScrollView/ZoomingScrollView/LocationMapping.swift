//
//  LocationMapping.swift
//  ZoomingScrollView
//
//  Created by w91379137 on 2016/9/18.
//  Copyright © 2016年 w91379137. All rights reserved.
//

import UIKit

class LocationMapping: NSObject {
    
    //實際值 轉換到 繪圖值 所乘倍數
    private(set) var scale : CGFloat
    
    //MARK: - Life Cycle
    init(scale : CGFloat) {
        self.scale = scale
        super.init()
    }
    
    //MARK: - Convert Real to Draw
    func distanceReal2Draw(_ value : CGFloat) -> CGFloat {
        return value * scale
    }
    
    func pointReal2Draw(_ point : CGPoint) -> CGPoint {
        return CGPoint(x: distanceReal2Draw(point.x),
                       y: distanceReal2Draw(point.y))
    }
    
    func pointsReal2Draw(_ points : [CGPoint]) -> [CGPoint] {
        return points.map({ (point) -> CGPoint in
            return self.pointReal2Draw(point)
        })
    }
    
    //MARK: - Convert Draw to Real
    func distanceDraw2Real(_ value : CGFloat) -> CGFloat {
        return value / scale
    }
    
    func pointDraw2Real(_ point : CGPoint) -> CGPoint {
        return CGPoint(x: distanceDraw2Real(point.x),
                       y: distanceDraw2Real(point.y))
    }
    
    func pointsDraw2Real(_ points : [CGPoint]) -> [CGPoint] {
        return points.map({ (point) -> CGPoint in
            return self.pointDraw2Real(point)
        })
    }
}
