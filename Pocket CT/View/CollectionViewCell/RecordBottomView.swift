//
//  RecordBottomView.swift
//  ShowPageViewcontroller
//
//  Created by ZouYa on 2020/10/24.
//  Copyright © 2020 ZouYa. All rights reserved.
//

import UIKit

class RecordBottomView: UIView {

//    var selectBtn = UIButton()
//    var selectLabel = UILabel()
    var confirmBtn = UIButton()
    var numberOfSelectedItems = UILabel()
    var bottomSelectLabel = UILabel()
    var bottomSelectButton = UIButton()
    
    var isDeleted:Bool!
    var isCompared:Bool!
    var isShared:Bool!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame:CGRect,delete:Bool,compare:Bool,share:Bool){
        self.init(frame:frame)
        
        self.isDeleted = delete
        self.isCompared = compare
        self.isShared = share
        
        addSubview(confirmBtn)
        addSubview(numberOfSelectedItems)
        addSubview(bottomSelectLabel)
        addSubview(bottomSelectButton)
        self.backgroundColor = .white
        
        setupUI()
    }
    
    private func setupUI(){
        backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 0.8))
        lineView.backgroundColor = #colorLiteral(red: 0.89826864, green: 0.89826864, blue: 0.89826864, alpha: 1)
        addSubview(lineView)

        if isDeleted {
            // 将删除按钮设置为 garbageBin
            confirmBtn.setImage(UIImage(named: "garbageBin.png"), for: .normal)
            confirmBtn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                confirmBtn.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -27),
                confirmBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -heightOfAddtionalFooter/2)
            ])
            
            // 设置选中的 照片 和 图册
            numberOfSelectedItems.textColor = .black
            numberOfSelectedItems.text = "未选择照片及图册"
            numberOfSelectedItems.font = .monospacedSystemFont(ofSize: 18, weight: .medium)
            numberOfSelectedItems.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                numberOfSelectedItems.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                numberOfSelectedItems.centerYAnchor.constraint(equalTo: confirmBtn.centerYAnchor)
            ])
            
            bottomSelectButton.isSelected = false
            bottomSelectButton.setImage(UIImage(named: "checkboxEmpty"), for: .normal)
            bottomSelectButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bottomSelectButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
                bottomSelectButton.centerYAnchor.constraint(equalTo: confirmBtn.centerYAnchor),
                bottomSelectButton.widthAnchor.constraint(equalToConstant: 24),
                bottomSelectButton.heightAnchor.constraint(equalToConstant: 24)
            ])
            
            bottomSelectLabel.text = "全选"
            bottomSelectLabel.textColor = .black
            bottomSelectLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bottomSelectLabel.leftAnchor.constraint(equalTo: bottomSelectButton.rightAnchor, constant: 6),
                bottomSelectLabel.centerYAnchor.constraint(equalTo: confirmBtn.centerYAnchor),
                bottomSelectLabel.widthAnchor.constraint(equalToConstant: 80),
                bottomSelectLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
            
        }else if isCompared || isShared{
            confirmBtn.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            confirmBtn.layer.cornerRadius = 16
            confirmBtn.setTitle(isShared ? "分享" : "对比", for: .normal)
            confirmBtn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                confirmBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
                confirmBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
                confirmBtn.widthAnchor.constraint(equalToConstant: self.frame.width / 2.2),
                confirmBtn.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    }
    
    @objc private func shareClicked() {
        print("点击分享按钮")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
