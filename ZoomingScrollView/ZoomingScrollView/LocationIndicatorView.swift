//
//  LocationView.swift
//  ZoomingScrollView
//
//  Created by w91379137 on 2016/9/4.
//  Copyright © 2016年 w91379137. All rights reserved.
//

import UIKit

@objc protocol LocationIndicatorViewDelegate : NSObjectProtocol {
    func beganPan(_ view : LocationIndicatorView)
    func requestChange(_ view : LocationIndicatorView, translate : CGPoint) -> CGPoint
    func locationUpdate(_ view : LocationIndicatorView, translate : CGPoint)
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
        let imageView = UIImageView(frame : CGRect.zero)
        
        imageView.image = UIImage(named: "point80.png")
        imageView.contentMode = .center
        self.addSubview(imageView)
        imageView.frame = self.bounds
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.bringSubview(toFront: self.nameLabel)
        return imageView
    }()
    
    lazy var nameLabel : UILabel = {
        let nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.textAlignment = .center
        nameLabel.textColor = UIColor.red
        
        self.addSubview(nameLabel)
        nameLabel.frame = self.bounds
        nameLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return nameLabel
    }()
    
    var name = String() {
        didSet {
            self.nameLabel.text = self.name
        }
    }
    
    var pointerAngle = 0.0 {
        didSet {
            let angle = self.pointerAngle / 180.0 * M_PI
            self.imageView.transform =
                CGAffineTransform.init(rotationAngle: CGFloat(angle))
        }
    }
    
    //MARK: - Life Cycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.alpha = normalAlpha
        _ = self.pan
        _ = self.imageView
    }
    
    //MARK: - Point 關於指針所指位置
    func set(size : CGSize, pointTo point : CGPoint) {
        let offset =
            self.locationPoint(bounds: CGRect(origin: CGPoint.zero,
                                              size: size))
        let origin =
            CGPoint(x: point.x - offset.x,
                    y: point.y - offset.y)
        
        self.frame = CGRect(origin: origin, size: size)
    }
    
    //回傳 圖片指針所指的點 在自己的view 裡面
    func locationPoint(bounds : CGRect? = nil) -> CGPoint {
        let bounds = bounds ?? self.bounds
        
        let length = Double(bounds.width / 2)
        let angle = self.pointerAngle / 180.0 * M_PI
        
        return CGPoint(x: bounds.midX + CGFloat(cos(angle) * length),
                       y: bounds.midY + CGFloat(sin(angle) * length))
    }
    
    
    //MARK: - Action
    func panAciton(sender : UIPanGestureRecognizer) {
        
        switch sender.state {
        case .began:
            self.alpha = focusAlpha
            self.delegate?.beganPan(self)
        case .ended, .cancelled:
            self.alpha = normalAlpha
        default : break
        }
        
        var offset = sender.translation(in: sender.view)
        sender.setTranslation(CGPoint.zero, in: sender.view)
        
        if let delegate = self.delegate {
            offset = delegate.requestChange(self, translate: offset)
        }
        
        self.transform = self.transform.translatedBy(x: offset.x, y: offset.y)
        
//        self.updateSerialNumberRandomKey =
//            "\(Int(Date().timeIntervalSince1970 * 1000))\(arc4random_uniform(1000))"
        self.delegate?.locationUpdate(self, translate: offset)
    }
    
    //Leader / Follower
    var leaderIndicatorKey = String()
    var leaderDistance : CGFloat = 0
    
    var followerIndicatorTableDict = [String : CGFloat]()
    //var updateSerialNumberRandomKey = String()
}
