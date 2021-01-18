//
//  ShowRecordCollectionReusableView.swift
//  ShowPageViewcontroller
//
//  Created by ZouYa on 2020/10/23.
//  Copyright © 2020 ZouYa. All rights reserved.
//

import UIKit
import AudioToolbox

/// 记录对比选中的indexPath数，先进先淘汰，容量为2
var headStateQueue = Array<Int>()

/// 头视图
class ShowRecordCollectionReusableView: UICollectionReusableView {
    
    static let Id = "ShowRecordCollectionReusableView"
    
    var timeLabel: UILabel!
    var imageView: UIImageView!
    var browseBtn: UIButton!
    
    var isAllSelectedInSection = false
    
    //对比模式下选中
    var isComparison = false{
        didSet {
            resizeLayoutView()
        }
    }
   
    var isSharing = false{
        didSet {
            resizeLayoutView()
        }
    }
    
    var isEdited = false {
        didSet {
            resizeLayoutView()
        }
    }
    
    var indexPath: IndexPath!
    
    override init(frame:CGRect){
        super.init(frame: frame)
        
        setupUI()
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(clicked(_:)))
        gr.numberOfTapsRequired = 1
        self.addGestureRecognizer(gr)
        
        //MARK:编辑
        NotificationCenter.default.addObserver(forName: .init("edited"), object: nil, queue: .main) { (note) in
            if let info = note.userInfo?["isEdited"] {
                self.isEdited = info as! Bool
            }
        }
        
        //对比接收消息，改变布局！
        NotificationCenter.default.addObserver(forName: .init("compare"), object: nil, queue: .main) { (note) in
            if let info = note.userInfo?["isCompare"]{
                self.isComparison = info as! Bool
            }
        }
        
        //共享接收消息，改变布局！
        NotificationCenter.default.addObserver(forName: .init("share"), object: nil, queue: .main) { (note) in
            if let info = note.userInfo?["isSharing"]{
                self.isSharing = info as! Bool
            }
        }
    }
    
    func setupUI(){
        timeLabel = UILabel(frame: CGRect(x: 10, y: 15, width: 200, height: 20))
        timeLabel.textColor = .black
        timeLabel.font = .boldSystemFont(ofSize: 18)
        addSubview(timeLabel)
        
        imageView = UIImageView(frame: CGRect(x: 5, y: 15, width: 20, height: 20))
        imageView.image = UIImage(named: "checkboxEmpty.png")
        addSubview(imageView)
        
        imageView.alpha = 0
        
        browseBtn = UIButton()
        browseBtn.setTitle("深度浏览", for: UIControl.State())
        browseBtn.setTitleColor(.white, for: UIControl.State.normal)
        browseBtn.backgroundColor = UIColor(displayP3Red: 0.13, green: 0.65, blue: 0.8, alpha: 1)
        browseBtn.layer.cornerRadius = 15
        browseBtn.titleLabel?.font = .systemFont(ofSize: 14.5)
        browseBtn.addTarget(self, action: #selector(browseClicked), for: .touchUpInside)
        addSubview(browseBtn)
        browseBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            browseBtn.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
            browseBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            browseBtn.widthAnchor.constraint(equalToConstant: 80),
            browseBtn.heightAnchor.constraint(equalToConstant: self.frame.height * 0.6)
        ])
    }
    
    func configTime(with time: String, indexPath: IndexPath, isAllSelectedInSection: Bool) {
        self.isAllSelectedInSection = isAllSelectedInSection
        timeLabel.text = time
        self.indexPath = indexPath
        
        imageView.image = isAllSelectedInSection ? UIImage(named: "checkboxChoosed.png") : UIImage(named: "checkboxEmpty.png")
    }
    
    //MARK:编辑模式变换视图
    func resizeLayoutView() {
//        print(timeLabel.text!, isEdited, isComparison)
        if isEdited || isComparison || isSharing{
            UIView.animate(withDuration: 0.2) {
                self.timeLabel.frame = .init(x: 35, y: 15, width: 200, height: 20)
                self.imageView.alpha = 1
                self.browseBtn.alpha = 0
            }
            
        } else {
            UIView.animate(withDuration: 0.2) {
                self.timeLabel.frame = .init(x: 10, y: 15, width: 200, height: 20)
                self.imageView.alpha = 0
                self.browseBtn.alpha = 1
            }
            imageView.image = UIImage(named: "checkboxEmpty.png")
        }
    }
    
    //MARK:单击头部视图
    @objc private func clicked(_ sender: UITapGestureRecognizer) {
        if isEdited {
            if isAllSelectedInSection {
                //如果目前是全选状态，那么点击使得状态变为全不选
                imageView.image = UIImage(named: "checkboxEmpty.png")
            } else {
                imageView.image = UIImage(named: "checkboxChoosed.png")
            }
            
            isAllSelectedInSection.toggle()
            
            headStateArr[indexPath.section] = isAllSelectedInSection
            
            NotificationCenter.default.post(name: .init("allSelected"), object: nil, userInfo: ["allSelected": isAllSelectedInSection, "section": indexPath.section])
            
            //MARK:对比模式头部选中逻辑
        }else if isComparison{
            let index = indexPath.section
            //当前分组在队列中
            if let i = headStateQueue.firstIndex(of: index){
                imageView.image = UIImage(named: "checkboxEmpty.png")
                // 张崇昊 在这里修改过
                // 原始语句如下
                // NotificationCenter.default.post(name: .init("comparison"), object: nil, userInfo: ["selectedNum": headStateQueue.count - 1])
                NotificationCenter.default.post(name: .init("comparison"), object: nil, userInfo: ["selectedNum": headStateQueue.count - 1, "section": headStateQueue[i]])
                headStateQueue.remove(at: i)
            }
            else{
                if headStateQueue.count == 2{
                    //震动反馈
                    AudioServicesPlaySystemSound(1519);
                }
                else{
                    imageView.image = UIImage(named: "checkboxChoosed.png")
                    headStateQueue.append(index)
                    // 张崇昊 在这里修改过
                    // 原始语句如下
                    // NotificationCenter.default.post(name: .init("comparison"), object: nil, userInfo: ["selectedNum": headStateQueue.count, "section": headStateQueue[0]])
                    NotificationCenter.default.post(name: .init("comparison"), object: nil, userInfo: ["selectedNum": headStateQueue.count, "section": headStateQueue[headStateQueue.count - 1]])
                }
            }
        }
        else if isSharing{
            let index = indexPath.section
            //当前分组在队列中
            if let i = headStateQueue.firstIndex(of: index){
                imageView.image = UIImage(named: "checkboxEmpty.png")
                // 张崇昊 在这里修改过
                // 原始语句如下
                // NotificationCenter.default.post(name: .init("comparison"), object: nil, userInfo: ["selectedNum": headStateQueue.count - 1])
                NotificationCenter.default.post(name: .init("comparison"), object: nil, userInfo: ["selectedNum": headStateQueue.count - 1, "section": headStateQueue[i]])
                headStateQueue.remove(at: i)
            }
            else{
                if headStateQueue.count == 1{
                    //震动反馈
                    AudioServicesPlaySystemSound(1519);
                }
                else{
                    imageView.image = UIImage(named: "checkboxChoosed.png")
                    headStateQueue.append(index)
                    NotificationCenter.default.post(name: .init("comparison"), object: nil, userInfo: ["selectedNum": headStateQueue.count, "section": headStateQueue[headStateQueue.count - 1]])
                }
            }
        }
    }
    
    // MARK:当天浏览
    @objc private func browseClicked(){
        NotificationCenter.default.post(name: .init("albumBrowse"), object: nil, userInfo: ["section": indexPath.section])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


/// 尾视图
class ShowRecordCollectionReusableFooterView: UICollectionReusableView {
    static let Id = "ShowRecordCollectionReusableFooterView"
    var backView: UIView!
    
    override init(frame:CGRect){
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        backView = UIView()
        addSubview(backView)
//        backView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        backView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 15),
            backView.rightAnchor.constraint(equalTo: backView.rightAnchor),
            backView.widthAnchor.constraint(equalToConstant: self.frame.width),
            backView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
