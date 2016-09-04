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
        
        for index_x in 0..<2 {
            for index_y in 0..<2 {
                
                let realPoint =
                    CGPoint.init(x: lenght + CGFloat(index_x * 2) * lenght,
                                 y: lenght + CGFloat(index_y * 2) * lenght)
                
                let locationIndicator = LocationIndicatorView()
                locationIndicator.name = "Position_\(index_x)_\(index_y)"
                locationIndicator.pointerAngle =
                    Double((index_x + index_y) * 90)
                
                //locationIndicator.backgroundColor = UIColor.brown
                
                
                
                let boardPoint =
                    self.boardViewController.convertRealPoint2Board(realPoint)
                
                //指針的偏差
                let offset =
                    locationIndicator.locationPoint(bounds: CGRect(origin: CGPoint.zero,
                                                                   size: controlSize))
                
                let origin =
                    CGPoint(x: boardPoint.x - offset.x,
                            y: boardPoint.y - offset.y)
                locationIndicator.frame = CGRect(origin: origin,
                                        size: controlSize)
                self.boardViewController.addLocationIndicator(locationIndicator)
            }
        }
        
        let locationIndicator = LocationIndicatorView()
        locationIndicator.name = "follow_Position_0_0"
        let realPoint = CGPoint.init(x: 150, y: 150)
        let boardPoint = self.boardViewController.convertRealPoint2Board(realPoint)
        let offset =
            locationIndicator.locationPoint(bounds: CGRect(origin: CGPoint.zero,
                                                           size: controlSize))
        let origin =
            CGPoint(x: boardPoint.x - offset.x,
                    y: boardPoint.y - offset.y)
        locationIndicator.frame = CGRect(origin: origin,
                                         size: controlSize)
        self.boardViewController.addLocationIndicator(locationIndicator)
        
        //Position_0_0 connect
        self.boardViewController.connect(leaderKey: "Position_0_0",
                                         follower: locationIndicator,
                                         distance: 100)
    }
    
    //MARK: -
    @IBAction func printPoints() {
        self.boardViewController.printPoints()
    }
}
