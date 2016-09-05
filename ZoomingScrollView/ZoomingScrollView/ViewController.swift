//
//  ViewController.swift
//  ZoomingScrollView
//
//  Created by w91379137 on 2016/9/2.
//  Copyright © 2016年 w91379137. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var baseView : UIView! {
        didSet {
            self.baseView.addSubview(self.boardViewController.view)
            boardViewController.view.frame = baseView.bounds
            boardViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    let boardViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LocationIndicatorBoardViewController")
        as! LocationIndicatorBoardViewController
    
    let lenght = CGFloat(100) //圖片上每個正方形邊長 100
    let controlSize = CGSize(width: 80, height: 80) //放大後的 控制元件大小
    
    //MARK: - Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var points = [CGPoint]()
        points.append(CGPoint(x: 200, y: 200))
        points.append(CGPoint(x: 200, y: 400))
        points.append(CGPoint(x: 200, y: 600))
        points.append(CGPoint(x: 400, y: 600))
        points.append(CGPoint(x: 600, y: 600))
        points.append(CGPoint(x: 600, y: 400))
        points.append(CGPoint(x: 600, y: 200))
        
        var pointKeyList = [String]()
        for (index, point) in points.enumerated() {
            let locationIndicator = LocationIndicatorView()
            locationIndicator.name = "Position_\(point)"
            
            switch index {
            case 0...1: locationIndicator.pointerAngle = 0
                break
            case 2...4: locationIndicator.pointerAngle = -90
                break
            case 5...6: locationIndicator.pointerAngle = -180
                break
            default :
                break
            }
            
            self.boardViewController.addLocationIndicator(locationIndicator,
                                                          realPoint: point,
                                                          size: controlSize)
            
            pointKeyList.append(locationIndicator.name)
        }
        
        
        self.boardViewController.pointKeyListArray = [pointKeyList]
    }
    
    func test16Mode() {
        var pointKeyListArray = [[String]]()
        
        for index_x in 0..<4 {
            
            var pointKeyList = [String]()
            
            for index_y in 0..<4 {
                
                let realPoint = CGPoint(x: CGFloat(index_x * 2 + 1) * lenght,
                                        y: CGFloat(index_y * 2 + 1) * lenght)
                let locationIndicator = LocationIndicatorView()
                locationIndicator.name = "Position_\(index_x)_\(index_y)"
                locationIndicator.pointerAngle = Double((index_x + index_y) * 90)
                //locationIndicator.backgroundColor = UIColor.brown
                
                self.boardViewController.addLocationIndicator(locationIndicator,
                                                              realPoint: realPoint,
                                                              size: controlSize)
                
                pointKeyList.append(locationIndicator.name)
            }
            pointKeyListArray.append(pointKeyList)
        }
        
        let realPoint = CGPoint.init(x: 150, y: 150)
        
        let locationIndicator = LocationIndicatorView()
        locationIndicator.name = "follow_Position_0_0"
        
        self.boardViewController.addLocationIndicator(locationIndicator,
                                                      realPoint: realPoint,
                                                      size: controlSize)
        
        //Position_0_0 connect
        self.boardViewController.connect(leaderKey: "Position_0_0",
                                         follower: locationIndicator,
                                         distance: 100)
        
        //連線
        pointKeyListArray.append(["follow_Position_0_0", "Position_0_0"])
        pointKeyListArray.append(["Position_0_0", "Position_1_1", "Position_2_2", "Position_3_3"])
        self.boardViewController.pointKeyListArray = pointKeyListArray
    }
    
    //MARK: -
    @IBAction func printPoints() {
        self.boardViewController.printPoints()
    }
}
