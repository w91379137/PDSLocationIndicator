//
//  LocationIndicatorBoardViewController.swift
//  ZoomingScrollView
//
//  Created by w91379137 on 2016/9/4.
//  Copyright © 2016年 w91379137. All rights reserved.
//

import UIKit

let scaleNormal = CGFloat(0.25)
let scaleBig = CGFloat(1)
//IB上面有設定
//在 Normal 1 Big 5 的情況 LocationView 會拖曳困難

@objc protocol LocationBoardViewControllerDelegate : NSObjectProtocol {
    func pointsUpdate(_ locationBoardViewController : LocationBoardViewController)
}

class LocationBoardViewController: UIViewController,
UIScrollViewDelegate, LocationIndicatorViewDelegate {
    
    var delegate : LocationBoardViewControllerDelegate? = nil
    var indicatorTableDict = [String : LocationIndicatorView]()
    
    //ScrollView
    @IBOutlet var scrollView : UIScrollView! {
        didSet {
            self.scrollView.minimumZoomScale = scaleNormal
            self.scrollView.maximumZoomScale = scaleBig
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
            self.scrollView.addGestureRecognizer(tap)
        }
    }
    
    lazy var containerView : UIView = {
        return self.scrollView.subviews[0]
    }()
    
    //Image
    var image : UIImage? = nil {
        didSet {
            if isViewLoaded {
                self.imageView.image = self.image
            }
        }
    }
    @IBOutlet var imageView : UIImageView! {
        didSet {
            self.imageView.image = self.image
        }
    }
    
    //Zoom
    enum ZoomStatus {
        case normal
        case mid
        case big
    }
    
    var zoomStatus : ZoomStatus = .normal {
        didSet {
            
            var scale : CGFloat? = nil
            
            switch self.zoomStatus {
            case .normal: scale = scaleNormal
            case .big: scale = scaleBig
            default: break
            }
            
            if let scale = scale {
                self.scrollView.setZoomScale(scale, animated: false)
            }
        }
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.zoomStatus = .normal
    }
    
    //MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.containerView
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let pan = scrollView.panGestureRecognizer
        if pan.numberOfTouches == 1 {
            let point = pan.location(ofTouch: 0, in: scrollView)
            self.detectToZoomIn(point: point)
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale == scaleNormal {
            self.zoomStatus = .normal
        }
        else if scrollView.zoomScale == scaleBig {
            self.zoomStatus = .big
        }
        else {
            self.zoomStatus = .mid
        }
    }
    
    //MARK: - LocationIndicatorViewDelegate
    func beganPan(_ view : LocationIndicatorView) {
        
        //換算成縮小時的座標
        var point = view.convert(view.locationPoint(), to: self.containerView)
        point = CGPoint(x: point.x * scaleNormal / scaleBig,
                        y: point.y * scaleNormal / scaleBig)
        self.detectToZoomIn(point: point)
    }
    
    func requestChange(_ view : LocationIndicatorView, translate : CGPoint) -> CGPoint {
        
        guard let leader = self.indicatorTableDict[view.leaderIndicatorKey] else {
            return translate
        }
        
        let oldPoint = view.convert(view.locationPoint(), to: self.containerView)
        let newPoint = CGPoint(x: oldPoint.x + translate.x,
                               y: oldPoint.y + translate.y)
        let leaderPoint = leader.convert(leader.locationPoint(), to: self.containerView)
        
        var xDist = newPoint.x - leaderPoint.x
        var yDist = newPoint.y - leaderPoint.y
        let newDistance = sqrt(xDist * xDist + yDist * yDist)
        
        xDist = xDist / newDistance * view.leaderDistance
        yDist = yDist / newDistance * view.leaderDistance
        
        return CGPoint(x: leaderPoint.x + xDist - oldPoint.x,
                       y: leaderPoint.y + yDist - oldPoint.y)
    }
    
    func locationUpdate(_ view : LocationIndicatorView, translate : CGPoint) {
        
        //TODO: 目前先設計一層 往後多層連動
        for (key, _) in view.followerIndicatorTableDict {
            if let follower = self.indicatorTableDict[key] {
                follower.frame =
                    follower.frame.offsetBy(dx: translate.x, dy: translate.y)
            }
        }
        
        self.delegate?.pointsUpdate(self)
    }
    
    //MARK: - Location Indicator
    func addLocationIndicator(_ locationIndicator : LocationIndicatorView) {
        
        locationIndicator.delegate = self
        self.containerView.addSubview(locationIndicator)
        
        if locationIndicator.name.isEmpty {
            fatalError("locationIndicator name isEmpty")
        }
        self.indicatorTableDict[locationIndicator.name] = locationIndicator
    }
    
    func connect(leaderKey : String,
                 follower : LocationIndicatorView,
                 distance : CGFloat) {
        
        if let leader = self.indicatorTableDict[leaderKey] {
            leader.followerIndicatorTableDict[follower.name] = distance
            follower.leaderIndicatorKey = leaderKey
            follower.leaderDistance = distance
            
            //調整連結距離
            let offset = self.requestChange(follower, translate: CGPoint.zero)
            follower.frame =
                follower.frame.offsetBy(dx: offset.x, dy: offset.y)
        }
        else {
            print("leader \(leaderKey) not found")
        }
    }
    
    //MARK: - Action
    func tapAction(sender : UITapGestureRecognizer) {
        
        switch self.zoomStatus {
        case .normal:
            let point = sender.location(in: sender.view)
            self.detectToZoomIn(point: point)
        default:
            self.animateAction {
                self.zoomStatus = .normal
            }
        }
    }
    
    func detectToZoomIn(point : CGPoint) {
        if self.zoomStatus == .normal {
            
            self.animateAction {
                self.zoomStatus = .big
                
                let width = self.scrollView.bounds.width
                let height = self.scrollView.bounds.height
                
                var offsetX = point.x / scaleNormal * scaleBig - width / 2
                offsetX = min(max(offsetX, 0),
                              width / scaleNormal * scaleBig  - width)
                
                var offsetY = point.y / scaleNormal * scaleBig - height / 2
                offsetY = min(max(offsetY, 0),
                              height / scaleNormal * scaleBig  - height)
                
                let offset =
                    CGPoint(x: offsetX,
                            y: offsetY)
                self.scrollView.contentOffset = offset
            }
        }
    }
    
    func animateAction(block : @escaping () -> ()) {
        UIView.animate(withDuration: 0.25) {
            block()
        }
    }
}

