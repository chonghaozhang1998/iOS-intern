//
//  SingleCTView.swift
//  demo_1
//
//  Created by RodinYTY on 2020/8/5.
//  Copyright © 2020 RodinYTY. All rights reserved.
//

import UIKit
import SnapKit

class SingleCTView: UIView {
    
    /// ct图显示界面
    private var ctView:UIImageView!
    
    /// 标记当前是否显示原始图。状态如果先显示标记过的图，需要手动修改该属性
    var isOrigin:Bool! = false {
        willSet{
            UIView.transition(with: self.ctView, duration: 0.28, options: .transitionCrossDissolve, animations: {[unowned self] in
                let image = newValue ? self.imageData[self.curIndex].originImage : self.imageData[self.curIndex].tagImage
                self.ctView.image = image.resize(to: self.ctView.bounds.size)
            }, completion: nil)
        }
    }
    
    //MARK:信息结构分开存储
    fileprivate struct WrappedImageInfo {
        var originImage: UIImage
        var tagImage: UIImage
        var rawAreaRatio: Double
    }
    
    /// CTImageGroup解析为UIImage和信息数组
    private var imageData: [WrappedImageInfo]!
    private var dateStr: String!
    
    var curIndex:Int = 0{
        //连带修改当前页码，图片
        willSet{
            currentPageLbl.text = String(newValue + 1)
            if abs(imageData[newValue].rawAreaRatio - 0) <= 10e-5{
                areaRatioLbl.text = "0%"
            } else{
                areaRatioLbl.text = "\(String(format:  "%.1f" , min(imageData[newValue].rawAreaRatio * 100 * 1.8, 95)))%"
            }
            setImageOfIndex(newValue)
        }
    }
    
    private var currentPageLbl:UILabel!
    private var pageNumLbl:UILabel!
    private var areaRatioLbl:UILabel!
    
    private var oldFrame:CGRect = CGRect.zero
    
    // MARK: - 重构init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// 传入分组构造CTView
    /// - Parameters:
    ///   - frame: 长方形的大小
    ///   - ctgroup: 分组
    required convenience init(frame: CGRect, ctgroup: CTImageGroup){
        self.init(frame: frame)
        self.imageData = ctgroup.images.map({ (image) -> WrappedImageInfo in
            WrappedImageInfo(originImage: UIImage(contentsOfFile: image.origin.absoluteString)!, tagImage: UIImage(contentsOfFile: image.tag.absoluteString)!, rawAreaRatio: image.infoDict.object(forKey: "ratio") as! Double)
        })
        self.dateStr = String(format: "%d月%d日", arguments: [ctgroup.month, ctgroup.day])
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 初始化界面
    private func initUI(){
        backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.6549019608, blue: 0.8, alpha: 1)
        let height = self.frame.height
        
        let cornerWidth:CGFloat = 6
        
        currentPageLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: height * 0.05))
        self.addSubview(currentPageLbl)
        currentPageLbl.text = "1"
        currentPageLbl.textColor = #colorLiteral(red: 0.7882352941, green: 0.8784313725, blue: 1, alpha: 1)
        currentPageLbl.textAlignment = .right
        currentPageLbl.font = .systemFont(ofSize: 15)
        currentPageLbl.snp.makeConstraints({(maker) in
            maker.centerY.equalTo(self.snp.bottom).offset(-(frame.height - frame.width)/2 + cornerWidth / 4)
            maker.left.equalTo(5)
            maker.width.equalTo(25)
            maker.height.equalTo(height * 0.05)
        })
        
        let lbl1 = UILabel()
        self.addSubview(lbl1)
        lbl1.textColor = #colorLiteral(red: 0.7882352941, green: 0.8784313725, blue: 1, alpha: 1)
        lbl1.text = "/"
        lbl1.textAlignment = .center
        lbl1.font = .systemFont(ofSize: 15)
        lbl1.snp.makeConstraints({(maker) in
            maker.bottom.equalTo(currentPageLbl.snp.bottom)
            maker.left.equalTo(currentPageLbl.snp.right).offset(5)
            maker.width.equalTo(5)
            maker.height.equalTo(height * 0.05)
        })

        pageNumLbl = UILabel()
        self.addSubview(pageNumLbl)
        pageNumLbl.text = String(imageData.count)
        pageNumLbl.textColor = #colorLiteral(red: 0.7882352941, green: 0.8784313725, blue: 1, alpha: 1)
        pageNumLbl.textAlignment = .left
        pageNumLbl.font = .systemFont(ofSize: 15)
        pageNumLbl.snp.makeConstraints({(maker) in
            maker.bottom.equalTo(currentPageLbl.snp.bottom)
            maker.left.equalTo(lbl1.snp.right).offset(5)
            maker.width.equalTo(30)
            maker.height.equalTo(height * 0.05)
        })

        areaRatioLbl = UILabel()
        self.addSubview(areaRatioLbl)
        if abs(imageData[curIndex].rawAreaRatio - 0) <= 10e-5{
            areaRatioLbl.text = "0%"
        } else{
            areaRatioLbl.text = "\(String(format:  "%.1f" , min(imageData[curIndex].rawAreaRatio * 100 * 1.8, 95)))%"
        }
        areaRatioLbl.textAlignment = .right
        areaRatioLbl.font = .systemFont(ofSize: 15)
        areaRatioLbl.textColor = .white
        areaRatioLbl.snp.makeConstraints({(maker) in
            maker.bottom.equalTo(currentPageLbl.snp.bottom)
            maker.right.equalTo(-10)
            maker.width.equalTo(45)
            maker.height.equalTo(height * 0.05)
        })

        let lbl2 = UILabel()
        self.addSubview(lbl2)
        lbl2.text = "病灶面积："
        lbl2.textAlignment = .right
        lbl2.font = .systemFont(ofSize: 15.2)
        lbl2.textColor = .white
        lbl2.snp.makeConstraints({(maker) in
            maker.bottom.equalTo(currentPageLbl.snp.bottom)
            maker.right.equalTo(areaRatioLbl.snp.left)
            maker.width.equalTo(80)
            maker.height.equalTo(height * 0.05)
        })
        
        ctView = UIImageView(frame: CGRect(x: -cornerWidth / 2, y: -cornerWidth / 2, width: CGFloat(frame.width + cornerWidth), height: CGFloat(frame.width + cornerWidth)))
        self.addSubview(ctView)

        ctView.layer.cornerRadius = 8
        ctView.layer.borderWidth = cornerWidth
        ctView.layer.borderColor = #colorLiteral(red: 0.9098039216, green: 0.9450980392, blue: 1, alpha: 1)
        ctView.layer.opacity = 0.95
        ctView.layer.masksToBounds = true
        
        let image = isOrigin ? imageData[curIndex].originImage : imageData[curIndex].tagImage
        ctView.image = image.resize(to: ctView.bounds.size)
        ctView.contentMode = .scaleToFill

        //按下放大
//        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(magnify_image))
//        ctView.addGestureRecognizer(singleTapGesture)
//        ctView.isUserInteractionEnabled = true

        //日期遮罩
        let dateView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width * 0.96, height: self.frame.height * 0.08))
        self.addSubview(dateView)
        dateView.backgroundColor = .black
        dateView.alpha = 0.35
        dateView.snp.makeConstraints { maker in
            maker.top.equalTo(self).offset(5)
            maker.centerX.equalToSuperview()
            maker.width.equalToSuperview().multipliedBy(0.96)
            maker.height.equalToSuperview().multipliedBy(0.08)
        }
        let dateLbl = UILabel()
        self.addSubview(dateLbl)
        dateLbl.text = dateStr
        dateLbl.textColor = .white
        dateLbl.alpha = 0.96
        dateLbl.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
        dateLbl.snp.makeConstraints { maker in
            maker.centerY.equalTo(dateView)
            maker.left.equalTo(self.frame.width * 0.04)
        }
    }
    
    // MARK: - 目标函数
    //放大图片
    @objc private func magnify_image(){
        /// 获取keyWindow
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let backGroundView = UIView(frame: window!.frame)
        /// 记录imageView初始frame，保证复原
        if let _ = ctView{
            oldFrame = ctView!.convert(ctView!.bounds, to: window)
            //放大显示的view
            let imageView = UIImageView(frame: oldFrame)
            imageView.contentMode = .scaleToFill
            backGroundView.backgroundColor = .black
            backGroundView.alpha = 0

            imageView.image = ctView!.image
            imageView.contentMode = .scaleToFill
            backGroundView.isUserInteractionEnabled = true
//          加上即只有点击黑色背景才能缩放
//          imageView.isUserInteractionEnabled = true
            window?.addSubview(backGroundView)
            window?.addSubview(imageView)
            /// 为背景View添加手势方法，实现点击复原
            let tap = EWTap(target: self, action: #selector(tapOnBackView))
            tap.backView = backGroundView
            tap.imageView = imageView
            backGroundView.addGestureRecognizer(tap)
            /// 实现动画效果
            UIView.animate(withDuration: 0.4) {
                let length = Int(window!.bounds.width * 0.9)
                imageView.frame = CGRect(x: horizontally(length), y: vertically(length), width: length, height: length)
                backGroundView.alpha = 0.6
            }
        }
        else{
            print("ctView is nil")
        }
    }
    
    
    /// 设置ctview第index张图片
    /// - Parameter index: 从0开始
    private func setImageOfIndex(_ index:Int){
        DispatchQueue.main.async {[unowned self] in
            let image = self.isOrigin ? self.imageData[index].originImage : self.imageData[index].tagImage
            self.ctView.image = image.resize(to: self.ctView.bounds.size)
        }
    }
    
    //MARK: - 共有接口
    
    //点击黑色背景返回
    @objc private func tapOnBackView(_ sender: EWTap){
        UIView.animate(withDuration: 0.4, animations: {
            sender.imageView?.frame = self.oldFrame
            sender.backView?.alpha = 0
        }, completion: { _ in
            sender.backView?.removeFromSuperview()
            sender.imageView?.removeFromSuperview()
        })
    }
    
}

// MARK: - 自定义手势类，延展属性
class EWTap: UITapGestureRecognizer {
    var backView: UIView?
    var imageView: UIImageView?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
}
