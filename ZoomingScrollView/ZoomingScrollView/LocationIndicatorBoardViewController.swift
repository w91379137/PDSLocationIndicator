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
    
    var indicatorTableDict = [String : LocationIndicatorView]()
    
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
    func beganPan(_ view : LocationIndicatorView) {
        
        //換算成縮小時的座標
        var point = view.locationPoint()
        point = CGPoint(x: point.x * scaleNormal / scaleBig,
                        y: point.y * scaleNormal / scaleBig)
        self.detectToZoomIn(point: point)
    }
    
    func requestChange(_ view : LocationIndicatorView, translate : CGPoint) -> CGPoint {
        
        guard let leader = self.indicatorTableDict[view.leaderIndicatorKey] else {
            return translate
        }
        
        let oldPoint = view.convert(view.locationPoint(), to: self.containerView)
        let newPoint = CGPoint.init(x: oldPoint.x + translate.x,
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
        
        //這邊目前先設計一層 往後可以做多層
        for (key, _) in view.followerIndicatorTableDict {
            if let follower = self.indicatorTableDict[key] {
                follower.frame =
                    follower.frame.offsetBy(dx: translate.x, dy: translate.y)
            }
        }
        
        self.updateCurve()
    }
    
    //MARK: - Connect
    func connect(leaderKey : String,
                 follower : LocationIndicatorView,
                 distance : CGFloat) {
        
        if let leader = self.indicatorTableDict[leaderKey] {
            leader.followerIndicatorTableDict[follower.name] = distance
            follower.leaderIndicatorKey = leaderKey
            follower.leaderDistance = self.convertRealLength2Board(distance)
            
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
        
        if locationIndicator.name.isEmpty {
            fatalError("locationIndicator name isEmpty")
        }
        self.indicatorTableDict[locationIndicator.name] = locationIndicator
    }
    
    func printPoints() {
        for (_, view) in self.indicatorTableDict {
            var point = view.convert(view.locationPoint(), to: self.containerView)
            point = self.convertBoard2RealPoint(point)
            print("\(view.name) : \(point.x) , \(point.y)")
        }
    }
    
    //MARK: - Convert
    func convertRealLength2Board(_ value : CGFloat) -> CGFloat {
        let boardSize = self.containerView.bounds.size
        let imageSize = self.imageView.image!.size
        return value * boardSize.width / imageSize.width
    }
    
    func convertRealPoint2Board(_ point : CGPoint) -> CGPoint {
        let x = self.convertRealLength2Board(point.x)
        let y = self.convertRealLength2Board(point.y)
        return CGPoint(x: x, y: y)
    }
    
    func convertBoard2RealLength(_ value : CGFloat) -> CGFloat {
        let boardSize = self.containerView.bounds.size
        let imageSize = self.imageView.image!.size
        return value / boardSize.width * imageSize.width
    }
    
    func convertBoard2RealPoint(_ point : CGPoint) -> CGPoint {
        let x = self.convertBoard2RealLength(point.x)
        let y = self.convertBoard2RealLength(point.y)
        return CGPoint(x: x, y: y)
    }
    
    //MARK: - Draw
    @IBOutlet var drawView : DrawView!
    var pointKeyListArray = [[String]]() {
        didSet {
            self.updateCurve()
        }
    }
    
    func updateCurve() {
        
        var pointListArray = [[CGPoint]]()
        
        for pointKeyList in self.pointKeyListArray {
            
            var pointList = [CGPoint]()
            for pointKey in pointKeyList {
                
                if let view = self.indicatorTableDict[pointKey] {
                    let point = view.convert(view.locationPoint(), to: self.containerView)
                    pointList.append(point)
                }
                else {
                    pointList = [CGPoint]()
                    print("PointKey: \(pointKey) not found")
                    break
                }
            }
            
            if pointList.count > 0 {
                pointListArray.append(pointList)
            }
        }
        
        drawView.pointListArray = pointListArray
        self.drawView.setNeedsDisplay()
    }
}

