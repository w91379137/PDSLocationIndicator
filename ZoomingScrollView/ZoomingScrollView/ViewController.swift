//
//  ViewController.swift
//  ZoomingScrollView
//
//  Created by w91379137 on 2016/9/2.
//  Copyright © 2016年 w91379137. All rights reserved.
//

import UIKit

class ViewController: UIViewController,
LocationBoardViewControllerDelegate {
    
    let drawWidth =
        (UIScreen.main.bounds.width - 10) *
        (scaleBig / scaleNormal) + 1 //跟xib有關
    let image = UIImage(named: "lattice.png")!
    
    lazy var locationMapping : LocationMapping = {
        return LocationMapping(scale: self.drawWidth / self.image.size.width)
    }()
    
    @IBOutlet var baseView : UIView! {
        didSet {
            self.baseView.addSubview(self.boardViewController.view)
            
            self.boardViewController.view.frame = baseView.bounds
            self.boardViewController.view.autoresizingMask =
                [.flexibleWidth, .flexibleHeight]
        }
    }
    
    lazy var boardViewController : LocationBoardViewController = {
        let boardViewController =
            UIStoryboard(name: "Main",
                         bundle: nil).instantiateViewController(withIdentifier: "LocationBoardViewController")
            as! LocationBoardViewController
        
        boardViewController.image = self.image
        boardViewController.delegate = self
        
        return boardViewController
    }()
    
    //MARK: - Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.demo16Points()
    }
    
    //MARK: - Demo
    let lenght = CGFloat(100) //圖片上每個正方形邊長 100
    let controlSize = CGSize(width: 80, height: 80) //放大後的 控制元件大小
    
    func demo3Side() {
        var points = [CGPoint]()
        points.append(CGPoint(x: 200, y: 200))
        points.append(CGPoint(x: 200, y: 400))
        points.append(CGPoint(x: 200, y: 600))
        points.append(CGPoint(x: 400, y: 600))
        points.append(CGPoint(x: 600, y: 600))
        points.append(CGPoint(x: 600, y: 400))
        points.append(CGPoint(x: 600, y: 200))
        
        points = self.locationMapping.pointsReal2Draw(points)
        
        var pointKeyList = [String]()
        for (index, point) in points.enumerated() {
            let locationIndicator = LocationIndicatorView()
            locationIndicator.name = "P_\(index)"
            
            var angle = 0.0
            switch index {
            case 2 : angle = -45
            case 3 : angle = -90
            case 4 : angle = -135
            case 5...6: angle = -180
            default : break }
            
            locationIndicator.pointerAngle = angle
            locationIndicator.set(size: controlSize, pointTo: point)
            
            self.boardViewController.addLocationIndicator(locationIndicator)
            pointKeyList.append(locationIndicator.name)
        }
        
        self.pointKeyListArray = [pointKeyList]
    }
    
    func demo16Points() {
        
        var pointKeyListArray = [[String]]()
        for index_x in 0..<4 {
            
            var pointKeyList = [String]()
            for index_y in 0..<4 {
                
                var point = CGPoint(x: CGFloat(index_x * 2 + 1) * lenght,
                                    y: CGFloat(index_y * 2 + 1) * lenght)
                point = self.locationMapping.pointReal2Draw(point)
                
                let locationIndicator = LocationIndicatorView()
                locationIndicator.name = "P_\(index_x)_\(index_y)"
                locationIndicator.pointerAngle = Double((index_x + index_y * 4) * 30)
                locationIndicator.set(size: controlSize, pointTo: point)
                
                self.boardViewController.addLocationIndicator(locationIndicator)
                pointKeyList.append(locationIndicator.name)
            }
            pointKeyListArray.append(pointKeyList)
        }
        
        var point = CGPoint(x: 150, y: 150)
        point = self.locationMapping.pointReal2Draw(point)
        
        let locationIndicator = LocationIndicatorView()
        locationIndicator.name = "F_P_0_0"
        locationIndicator.set(size: controlSize, pointTo: point)
        
        self.boardViewController.addLocationIndicator(locationIndicator)
        
        //Position_0_0 connect
        self.boardViewController.connect(leaderKey : "P_0_0",
                                         follower: locationIndicator,
                                         distance: self.locationMapping.distanceReal2Draw(100))
        
        //連線
        pointKeyListArray.append(["F_P_0_0", "P_0_0"])
        pointKeyListArray.append(["P_0_0", "P_1_1", "P_2_2", "P_3_3"])
        self.pointKeyListArray = pointKeyListArray
    }
    
    //MARK: - IBAction
    @IBAction func printPoints() {
        for (_, view) in self.boardViewController.indicatorTableDict {
            var point = view.convert(view.locationPoint(),
                                     to: self.boardViewController.containerView)
            point = self.locationMapping.pointDraw2Real(point)
            print("\(view.name) : \(point.x) , \(point.y)")
        }
    }
    
    //MARK: - LocationBoardViewControllerDelegate
    func pointsUpdate(_ locationBoardViewController : LocationBoardViewController) {
        self.updateCurve()
    }
    
    //MARK: - Draw
    lazy var drawView : PDSDrawLineView = {
        let addToView = self.boardViewController.imageView!
        
        let drawView = PDSDrawLineView(frame : addToView.bounds)
        drawView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        drawView.backgroundColor = UIColor.clear
        drawView.isUserInteractionEnabled = false
        
        addToView.addSubview(drawView)
        return drawView
    }()
    
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
                
                if let view = self.boardViewController.indicatorTableDict[pointKey] {
                    let point = view.convert(view.locationPoint(),
                                             to: self.boardViewController.containerView)
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
