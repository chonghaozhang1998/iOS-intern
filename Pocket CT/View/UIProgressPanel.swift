//
//  UIProgressPanel.swift
//  CTDemo
//
//  Created by RodinYTY on 2020/10/20.
//

import UIKit

open class UIProgressPanel: UIView {
    var progressView:UICircleProgressView!
    var label:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        self.alpha = 0.7
        
        let progressX = Int(frame.width * 0.15)
        let progressY = Int(frame.width * 0.15) - 6
        
        progressView = UICircleProgressView(frame: CGRect(x: progressX, y: progressY, width: Int(frame.width * 0.7), height: Int(frame.height * 0.7)), lineWidth: frame.width * 0.1)
        self.addSubview(progressView)

        label = UILabel()
        label.font = .systemFont(ofSize: frame.width * 0.1)
        label.text = "识别中"
        label.textColor = .white
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 6),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
        
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setProgress(progress: CGFloat){
        progressView.setProgress(value: progress)
    }
}
