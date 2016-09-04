//
//  ViewController.swift
//  ZoomingScrollView
//
//  Created by w91379137 on 2016/9/2.
//  Copyright © 2016年 w91379137. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var baseView : UIView!
    
    let boardViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LocationIndicatorBoardViewController")
        as! LocationIndicatorBoardViewController
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.baseView.addSubview(self.boardViewController.view)
        boardViewController.view.frame = baseView.bounds
        boardViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    //MARK: - 
    @IBAction func printPoints() {
        self.boardViewController.printPoints()
    }
}
