//
//  ViewController.swift
//  ZoomingScrollView
//
//  Created by w91379137 on 2016/9/2.
//  Copyright © 2016年 w91379137. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
    
    lazy var boardViewController : LocationIndicatorBoardViewController = {
        let boardViewController =
            UIStoryboard(name: "Main",
                         bundle: nil).instantiateViewController(withIdentifier: "LocationIndicatorBoardViewController")
            as! LocationIndicatorBoardViewController
        
        boardViewController.locationMapping = self.locationMapping
        boardViewController.image = self.image
        
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
            
            self.boardViewController.addLocationIndicatorToContainerView(locationIndicator)
            pointKeyList.append(locationIndicator.name)
        }
        
        self.boardViewController.pointKeyListArray = [pointKeyList]
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
                
                self.boardViewController.addLocationIndicatorToContainerView(locationIndicator)
                pointKeyList.append(locationIndicator.name)
            }
            pointKeyListArray.append(pointKeyList)
        }
        
        var point = CGPoint(x: 150, y: 150)
        point = self.locationMapping.pointReal2Draw(point)
        
        let locationIndicator = LocationIndicatorView()
        locationIndicator.name = "F_P_0_0"
        locationIndicator.set(size: controlSize, pointTo: point)
        
        self.boardViewController.addLocationIndicatorToContainerView(locationIndicator)
        
        //Position_0_0 connect
        self.boardViewController.connect(leaderKey: "P_0_0",
                                         follower: locationIndicator,
                                         distance: 100)
        
        //連線
        pointKeyListArray.append(["F_P_0_0", "P_0_0"])
        pointKeyListArray.append(["P_0_0", "P_1_1", "P_2_2", "P_3_3"])
        self.boardViewController.pointKeyListArray = pointKeyListArray
    }
    
    //MARK: - IBAction
    @IBAction func printPoints() {
        self.boardViewController.printPoints()
    }
}
