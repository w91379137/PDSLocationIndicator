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
    
    //放大後的 控制元件大小
    let controlSize = CGSize(width: 80, height: 80)
    
    //MARK: - Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //圖片上每個正方形邊長 100
        let lenght = CGFloat(100)
        
        var pointKeyListArray = [[String]]()
        
        for index_x in 0..<4 {
            
            var pointKeyList = [String]()
            
            for index_y in 0..<4 {
                
                let realPoint =
                    CGPoint.init(x: lenght + CGFloat(index_x * 2) * lenght,
                                 y: lenght + CGFloat(index_y * 2) * lenght)
                
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
