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
    
    //MARK: - Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //圖片每格 111
        //圖片總寬 888
        //放大倍率 5
        let lenght = self.baseView.bounds.width / 8 * (scaleBig / scaleNormal)
        
        for index_x in 0..<4 {
            for index_y in 0..<4 {
                let location = LocationIndicatorView()
                location.name = "Position_\(index_x)_\(index_y)"
                
                let size = CGSize(width: 120, height: 214)
                let origin =
                    CGPoint(x: lenght - size.width / 2 +
                            CGFloat(index_x * 2) * lenght,
                            y: lenght - size.height +
                            CGFloat(index_y * 2) * lenght)
                location.frame = CGRect.init(origin: origin, size: size)
                self.boardViewController.addLocationIndicator(location)
            }
        }
    }
    
    //MARK: - 
    @IBAction func printPoints() {
        
        //期望輸出每個標點在 圖片上的座標 而非 view 上的座標
        self.boardViewController.printPoints()
    }
}
