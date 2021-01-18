//
//  ShowRecordCollectionViewCell.swift
//  ShowPageViewcontroller
//
//  Created by ZouYa on 2020/10/22.
//  Copyright © 2020 ZouYa. All rights reserved.
//

import UIKit

class ShowRecordCollectionViewCell: UICollectionViewCell {
    
    static let Id = "ShowRecordCollectionViewCell"
    
    private var imageView: UIImageView!
    private var imageViewOverlay: UIView!
    private var imageViewSelected: UIImageView!
    private var imageViewUnselected: UIImageView!
    var infoLbl: UILabel!
    
    private var showSelectionIcons = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.width))
        addSubview(imageView)
        
        imageViewOverlay = UIView(frame: imageView.bounds)
        imageViewOverlay.backgroundColor = .clear
        addSubview(imageViewOverlay)
        
        imageViewSelected = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        imageViewSelected.image = UIImage(named: "checkboxChoosed.png")
        addSubview(imageViewSelected)
        
        imageViewUnselected = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        imageViewUnselected.image = UIImage(named: "checkboxEmpty.png")
        addSubview(imageViewUnselected)
        
        infoLbl = UILabel(frame: CGRect(x: 0, y: frame.height - 20, width: frame.width, height: 20))
        infoLbl.font = .systemFont(ofSize: 15)
        //默认颜色
        infoLbl.textColor = #colorLiteral(red: 0.2823529412, green: 0.3490196078, blue: 0.737254902, alpha: 1)
        infoLbl.textAlignment = .center
        addSubview(infoLbl)
    }
    
    
    /// 代理动态配置cell布局
    /// - Parameters:
    ///   - image: 显示的图片
    ///   - showSelectionIcons: 是否显示选择框
    ///   - rawAreaRatio: 原始病灶数据
    func configCell(with image: UIImage?, showSelectionIcons: Bool, rawAreaRatio: Double) {
        self.showSelectionIcons = showSelectionIcons
        if let image = image {
            imageView.image = image.resize(to: bounds.size)
        }
        if abs(rawAreaRatio - 0) <= 10e-5{
            let attri = NSMutableAttributedString(string: "病灶：0%")
            attri.addAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)], range: NSRange(location: 0, length: 3))
            attri.addAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)], range: NSRange(location: 3, length: attri.length - 3))
            infoLbl.attributedText = attri
//            infoLbl.text = "病灶：0%"
        }
        else{
            let attri = NSMutableAttributedString(string: "病灶：\(String (format:  "%.1f" , min(rawAreaRatio * 100 * 1.8, 95)))%")
            attri.addAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)], range: NSRange(location: 0, length: 3))
            attri.addAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor: UIColor.red], range: NSRange(location: 3, length: attri.length - 3))
            infoLbl.attributedText = attri
//            infoLbl.text = "病灶：\(String (format:  "%.1f" , rawAreaRatio * 100 * 1.8))%"
        }
        showSelectionOverlay()
    }
    
    private func showSelectionOverlay() {
        //只有选中才可以显示图标
        let alpha: CGFloat = (isSelected && showSelectionIcons) ? 1.0 : 0.0
        imageViewOverlay.alpha = alpha
        imageViewSelected.alpha = alpha
        imageViewUnselected.alpha = showSelectionIcons ? 1.0 : 0.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
        showSelectionIcons = false
        showSelectionOverlay()
    }
    
    //MARK:选中item
    override var isSelected: Bool {
        didSet {
            showSelectionOverlay()
            setNeedsLayout()
        }
    }
    
}
