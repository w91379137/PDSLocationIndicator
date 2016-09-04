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
    var pan : UIPanGestureRecognizer?
    
    //MARK: - Life Cycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.alpha = normalAlpha
        if self.pan == nil {
            let pan = UIPanGestureRecognizer(target: self,
                                             action: #selector(self.panAciton))
            self.addGestureRecognizer(pan)
            self.pan = pan
        }
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
        
        //TODO: 是不是能通知 Board 一起移動視角？
    }
    
    func locationPoint() -> CGPoint {
        return CGPoint(x: self.frame.midX,
                       y: self.frame.maxY)
    }
}
