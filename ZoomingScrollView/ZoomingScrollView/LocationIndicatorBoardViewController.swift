//
//  LocationIndicatorBoardViewController.swift
//  ZoomingScrollView
//
//  Created by w91379137 on 2016/9/4.
//  Copyright © 2016年 w91379137. All rights reserved.
//

import UIKit

let scaleNormal = CGFloat(0.2)
let scaleBig = CGFloat(1)
//在 Normal 1 Big 5 的情況 LocationView 會拖曳困難

class LocationIndicatorBoardViewController: UIViewController,
UIScrollViewDelegate, LocationIndicatorViewDelegate {
    
    @IBOutlet var scrollView : UIScrollView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
            self.scrollView.addGestureRecognizer(tap)
        }
    }
    
    lazy var containerView : UIView = {
        return self.scrollView.subviews[0]
    }()
    
    var moveViewArray = [LocationIndicatorView]()
    
    @IBOutlet var imageView : UIImageView!
    
    enum ZoomStatus {
        case normal
        case big
    }
    
    var zoomStatus : ZoomStatus = .normal {
        didSet {
            
            var scale : CGFloat
            
            switch self.zoomStatus {
            case .normal: scale = scaleNormal
            case .big: scale = scaleBig
            }
            
            if isViewLoaded {
                self.scrollView.minimumZoomScale = scale
                self.scrollView.maximumZoomScale = scale
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
        if pan.numberOfTouches > 0 {
            let point = pan.location(ofTouch: 0, in: scrollView)
            self.detectToZoomIn(point: point)
        }
    }
    
    //MARK: - LocationIndicatorViewDelegate
    func didTouchInside(view : LocationIndicatorView) {
        
        //換算成縮小時的座標
        var point = view.locationPoint()
        point = CGPoint(x: point.x * scaleNormal / scaleBig,
                        y: point.y * scaleNormal / scaleBig)
        self.detectToZoomIn(point: point)
    }
    
    //MARK: - Action
    func tapAction(sender : UITapGestureRecognizer) {
        if self.zoomStatus == .big {
            self.animateAction {
                self.zoomStatus = .normal
            }
        }
        else {
            let point = sender.location(in: sender.view)
            self.detectToZoomIn(point: point)
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
    
    //MARK: -
    func addLocationIndicator(_ locationIndicator : LocationIndicatorView) {
        locationIndicator.delegate = self
        self.containerView.addSubview(locationIndicator)
        self.moveViewArray.append(locationIndicator)
    }
    
    func printPoints() {
        for view in self.moveViewArray {
            print("\(view.name) : \(view.locationPoint())")
        }
    }
}
