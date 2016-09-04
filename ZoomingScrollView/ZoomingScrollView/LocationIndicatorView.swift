//
//  LocationView.swift
//  ZoomingScrollView
//
//  Created by w91379137 on 2016/9/4.
//  Copyright © 2016年 w91379137. All rights reserved.
//

import UIKit

@objc protocol LocationIndicatorViewDelegate : NSObjectProtocol {
    func didTouchInside(view : LocationIndicatorView)
}

let focusAlpha = CGFloat(1.0)
let normalAlpha = CGFloat(0.3)

class LocationIndicatorView: UIView {
    
    var delegate : LocationIndicatorViewDelegate?
    
    lazy var pan : UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self,
                                         action: #selector(self.panAciton))
        self.addGestureRecognizer(pan)
        return pan
    }()
    
    lazy var imageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "point.png"))
        self.addSubview(imageView)
        imageView.frame = self.bounds
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return imageView
    }()
    
    var name = String()
    
    //MARK: - Life Cycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.alpha = normalAlpha
        let _ = self.pan
        let _ = self.imageView
    }
    
    //MARK: - Action
    func panAciton(sender : UIPanGestureRecognizer) {
        
        switch sender.state {
        case .began:
            self.alpha = focusAlpha
            self.delegate?.didTouchInside(view: self)
        case .ended, .cancelled:
            self.alpha = normalAlpha
        default : break
        }
        
        let offset = sender.translation(in: sender.view)
        sender.setTranslation(CGPoint.zero, in: sender.view)
        
        self.transform = self.transform.translatedBy(x: offset.x, y: offset.y)
        
        //是不是能通知 Board 一起移動視角？
        //似乎會跟手勢位置不同
    }
    
    //回傳 圖片指針所指的點 在自己的view 裡面
    func locationPoint(bounds : CGRect? = nil) -> CGPoint {
        let bounds = bounds ?? self.bounds
        return CGPoint(x: bounds.midX,
                       y: bounds.maxY)
    }
}
