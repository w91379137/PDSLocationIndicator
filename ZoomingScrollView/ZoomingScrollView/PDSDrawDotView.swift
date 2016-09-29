//
//  DotDrawView.swift
//  SPELandMarkControl
//
//  Created by w91379137 on 2016/9/25.
//  Copyright © 2016年 w91379137. All rights reserved.
//

import UIKit

class PDSDrawDotView: UIView {

    var fillColor : UIColor? = nil
    
    var pointArray = [CGPoint]() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()!
        if let color = self.fillColor { context.setFillColor(color.cgColor) }
        
        let size = CGSize(width: 8, height: 8)
        for point in self.pointArray {
            let origin = CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2)
            context.fillEllipse(in: CGRect(origin: origin, size:size))
        }
    }
}
