//
//  ViewController.swift
//  LSFDoubleSider_Example
//
//  Created by 李胜锋 on 2020/2/8.
//  Copyright © 2020 李胜锋. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let frame = CGRect(x: 20, y: 100, width: self.view.frame.width - 40, height: 50)
        let slider = LSFDoubleSider(lowerValue: 20,
                                    upperValue: 80,
                                    minimumValue: 0,
                                    maximumValue: 100,
                                    trackHeight: 2,
                                    trackColors: [UIColor.red, UIColor.green],
                                    thumbColors: [UIColor.red, UIColor.green])
        slider.frame = frame
        self.view.addSubview(slider)
        slider.setup()
    }


}

