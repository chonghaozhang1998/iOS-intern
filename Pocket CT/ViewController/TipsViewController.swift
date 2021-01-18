//
//  TipsViewController.swift
//  Pocket CT
//
//  Created by RodinYTY on 2020/11/6.
//

import UIKit

class TipsViewController: UIViewController {

    var tipImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tipImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width * 1187 / 657))
        view.addSubview(tipImageView)
        tipImageView.image = UIImage(named: "explain")?.resize(to: tipImageView.bounds.size)
        
        let cross = UIButton(frame: CGRect(x: view.frame.width - 40, y: 15, width: 25, height: 25))
        cross.setBackgroundImage(UIImage(named: "cross"), for: UIControl.State())
        cross.addTarget(self, action: #selector(quit), for: .touchUpInside)
        view.addSubview(cross)
    }
    
    @objc func quit(){
        self.dismiss(animated: true, completion: nil)
    }
}
