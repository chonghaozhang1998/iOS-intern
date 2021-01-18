//
//  PopoverViewController.swift
//  ShowPageViewcontroller
//
//  Created by ZouYa on 2020/10/23.
//  Copyright © 2020 ZouYa. All rights reserved.
//

import UIKit

class PopoverViewController: UIViewController {
    
    var deleteBtn = UIButton()
    var compareBtn = UIButton()
    var shareBtn = UIButton()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.view.addSubview(deleteBtn)
        deleteBtn.frame = CGRect(x: -15, y: 18, width: screen_width / 3, height: 30)

        deleteBtn.setTitle("删除", for: .normal)
        deleteBtn.setTitleColor(.black, for: .normal)
        deleteBtn.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        self.view.addSubview(compareBtn)
        compareBtn.frame = CGRect(x: -15, y: 50, width: screen_width / 3, height: 30)
        compareBtn.setTitle("对比", for: .normal)
        compareBtn.setTitleColor(.black, for: .normal)
        compareBtn.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        self.view.addSubview(shareBtn)
        shareBtn.frame = CGRect(x: -15, y: 82, width: screen_width / 3, height: 30)
        shareBtn.setTitle("分享", for: .normal)
        shareBtn.setTitleColor(.black, for: .normal)
        shareBtn.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
    }
    
    @objc func buttonClicked(){
        self.dismiss(animated: true, completion: nil)
    }
    
}
