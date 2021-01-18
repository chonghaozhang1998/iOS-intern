//
//  BrowseViewController.swift
//  Pocket CT
//
//  Created by RodinYTY on 2020/10/30.
//

import UIKit
import SnapKit

class BrowseViewController: UIViewController {
    
    enum BrowseMode{
        case album
        case contrast
    }
    
    let NOT_PLAYING = 0, PLAYING = 1
    
    /// 当天浏览 / 对比
    var mode: BrowseMode!
    
    /// 当前诊断分组
    var ctGroup: CTImageGroup = CTImageGroup(year: 0, month: 0, day: 0, folder: nil, images: [])
    
    /// 用于对比的上一次诊断分组，若没有为nil
    var prectGroup: CTImageGroup?
    
    var titleLbl: UILabel!
    /// 模式切换按钮，如果没有上一次分组则不添加控件
    var modeSwitchBtn: UIButton?
    var runBtn: UIButton!
    var markBtn: UIButton!
    
    //展示ct图的控件
    var CTViewLen: CGFloat!
    private var ctView: SingleCTView!
    private var prectView: SingleCTView?
    private var lungView: UIImageView!
    
    private var aboveSlider: MarkSlider!
    private var underSlider: MarkSlider?
    private var lungSlider: MarkSlider?
    
    private var dottedLine: UIView?
    
    private var timer:Timer? = nil
    
    init(){
        super.init(nibName:nil, bundle:nil)
    }
    
    required convenience init(mode: BrowseMode, group: CTImageGroup, preGroup: CTImageGroup?){
        self.init()
        self.mode = mode
        self.ctGroup = group
        self.prectGroup = preGroup
        
        //测试：统一数组元素个数
        if preGroup != nil{
            let minCount:Int = min(group.images.count, preGroup!.images.count)
            self.ctGroup.images.removeLast(group.images.count - minCount)
            self.prectGroup!.images.removeLast(preGroup!.images.count - minCount)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - 页面布局
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        /*
         布局：
         刘海：heightOfAddtionalHeader
         页眉：10
         标题标签高度：30
         30
         1.12*CTViewLen
         对比按钮高度：70
         1.12*CTViewLen
         页脚：10
         底部安全区域高度：heightOfAddtionalFooter
         */
        
        //计算SingleView宽度
        let margin:CGFloat = heightOfAddtionalHeader + heightOfAddtionalFooter
        let midResult:CGFloat = view.frame.height - margin - 80 - 70
        CTViewLen = midResult / 2 / 1.12
        titleLbl = UILabel()
        view.addSubview(titleLbl)
        titleLbl.text = mode == BrowseMode.album ? "深度浏览" : "对比分析"
        titleLbl.textColor = #colorLiteral(red: 0.1294117647, green: 0.6549019608, blue: 0.8, alpha: 1)
        titleLbl.font = .monospacedSystemFont(ofSize: 18, weight: .medium)
        titleLbl.snp.makeConstraints({ maker in
            maker.top.equalToSuperview().offset(heightOfAddtionalHeader + 10)
            
            if prectGroup != nil{
                maker.centerX.equalToSuperview().offset(-view.frame.width * 0.01)
            } else{
                maker.centerX.equalToSuperview()
            }
            maker.width.equalTo(80)
            maker.height.equalTo(30)
        })
        
        let backBtn = UIButton()
        view.addSubview(backBtn)
        backBtn.setImage(UIImage(named: "back_green"), for: .normal)
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        backBtn.snp.makeConstraints { maker in
            maker.centerY.equalTo(titleLbl)
            maker.left.equalTo(27)
            maker.width.equalTo(22)
            maker.height.equalTo(22)
        }
        
        // 设置 historyButton
        if prectGroup != nil{
            modeSwitchBtn = UIButton()
            self.view.addSubview(modeSwitchBtn!)
            modeSwitchBtn?.snp.makeConstraints{ maker in
                maker.centerY.equalTo(titleLbl)
                maker.right.equalTo(0)
                maker.width.equalTo(101)
                maker.height.equalTo(32)
            }
            modeSwitchBtn?.setBackgroundImage(UIImage(named: mode == BrowseMode.album ? "contrastLast" : "contrastCancel"), for: .normal)
            modeSwitchBtn?.addTarget(self, action: #selector(modeSwitch), for: .touchUpInside)
        }
        
        lungView = UIImageView()
        lungView.image = UIImage(named: "lung")
        lungView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.9450980392, blue: 1, alpha: 1)
        lungView.layer.cornerRadius = 8
        view.addSubview(lungView)
        lungView.snp.makeConstraints{ maker in
            maker.left.equalToSuperview().offset(view.frame.width * 0.1)
            maker.bottom.equalToSuperview().offset(-CTViewLen * 0.06 - 10 - heightOfAddtionalFooter)
            maker.width.equalTo(CTViewLen)
            maker.height.equalTo(CTViewLen)
        }
        
        ctView = SingleCTView(frame: CGRect(x: 0, y: 0, width: CTViewLen, height: CTViewLen * 1.12), ctgroup: ctGroup)
        view.addSubview(ctView)
        ctView.snp.makeConstraints { maker in
            maker.centerX.equalTo(lungView)
            maker.top.equalTo(titleLbl.snp.bottom).offset(30)
            maker.width.equalTo(CTViewLen)
            maker.height.equalTo(CTViewLen * 1.12)
        }
        
        runBtn = UIButton()
        view.addSubview(runBtn)
        runBtn.tag = NOT_PLAYING
        runBtn.setBackgroundImage(UIImage(named: "play"), for: .normal)
//        runBtn.layer.shadowColor = UIColor(red: 0.07, green: 0.27, blue: 0.74, alpha: 0.37).cgColor
//        runBtn.layer.shadowOffset = CGSize(width: 0, height: 1)
//        runBtn.layer.shadowOpacity = 0
//        runBtn.layer.shadowRadius = 10
//        runBtn.addTarget(self, action: #selector(runBtnTouchDown), for: .touchDown)
        runBtn.addTarget(self, action: #selector(runBtnClicked), for: .touchUpInside)
        runBtn.snp.makeConstraints { maker in
            maker.left.equalTo(ctView)
            let other:CGFloat = 10 + 30 + 30 + 10
            let margin:CGFloat = heightOfAddtionalHeader + heightOfAddtionalFooter
            maker.centerY.equalTo(ctView.snp.bottom)
                .offset(CGFloat(view.frame.height - other - CGFloat(CTViewLen * 1.12 * 2) -  margin) / 2)
            maker.width.equalTo(74)
            maker.height.equalTo(34)
        }
        //如果只有一组图，不能播放
        if ctGroup.images.count == 1{
            runBtn.isEnabled = false
        }
        
        markBtn = UIButton()
        view.addSubview(markBtn)
        markBtn.setBackgroundImage(UIImage(named: "mark_gray"), for: .normal)
        markBtn.addTarget(self, action: #selector(markSwitch), for: .touchUpInside)
        markBtn.snp.makeConstraints { maker in
            maker.right.equalTo(ctView)
            maker.centerY.equalTo(runBtn)
            maker.width.equalTo(116.6)
            maker.height.equalTo(34)
        }
        
        //标记有病灶的index
        var focusMarkSet = Set<Int>()
        for (i, image) in ctGroup.images.enumerated(){
            if let rawAreaRatio = image.infoDict.object(forKey: "ratio") as? Double{
                //areaRatio不为0
                if abs(rawAreaRatio - 0) > 10e-5{
                    focusMarkSet.insert(i)
                }
            }
        }
        
        //FIXME: 深度模拟
        let depthArr = [-90, -100, -112, -121, -131, -146, -153, -165, -180,
                        -190, -198, -210, -225, -235, -250, -260, -280,
                        -292, -302, -320, -350, -360, -375, -386, -405]
        let preDepthArr = [-90,  -98, -114, -128, -135, -146, -153, -162, -182,
                           -192, -202, -210, -228, -239, -250, -263, -275,
                           -296, -303, -319, -348, -360, -375, -392, -402]
        //MARK: 上方slider初始化
        aboveSlider = MarkSlider(frame: CGRect(x: 0, y: 0, width: CTViewLen, height: 0),
                                 startPos: 10,
                                 endPos: 90,
                                 depthArr: depthArr[0..<ctGroup.images.count],
                                 focusIndexMark: focusMarkSet,
                                 leftBarColor: UIColor(red: 196, green: 220, blue: 255),
                                 rightBarColor: #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1),
                                 barHeight: 6)
        view.addSubview(aboveSlider)
        aboveSlider.setThumbImage(UIImage(named: "thumb1"), for: .normal)
        
        aboveSlider.addTarget(self, action: #selector(aboveSliderValueChanged), for: .valueChanged)
        aboveSlider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        aboveSlider.addTarget(self, action: #selector(sliderTouchAway), for: .touchUpInside)
        aboveSlider.addTarget(self, action: #selector(sliderTouchAway), for: .touchUpOutside)
        //需要先对横向的slider进行autolayout
        aboveSlider.snp.makeConstraints({(maker) in
            maker.centerX.greaterThanOrEqualTo(ctView.snp.right).offset(view.frame.width * 0.06)
            maker.centerX.lessThanOrEqualTo(view.snp.right).offset(-view.frame.width * 0.09)
            maker.centerY.equalTo(ctView.snp.centerY).offset(-CTViewLen * 0.03)
            maker.width.equalTo(CTViewLen)
        })
        aboveSlider.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
        
        //MARK: 下方元件初始化
        lungSlider = MarkSlider(frame: CGRect(x: 0, y: 0, width: CTViewLen * 0.84, height: 0),
                                startPos: 20,
                                endPos: 80,
                                depthArr: depthArr[0..<ctGroup.images.count],
                                focusIndexMark: focusMarkSet,
                                leftBarColor: UIColor(red: 0.13, green: 0.65, blue: 0.8, alpha: 1),
                                rightBarColor: UIColor(red: 196, green: 220, blue: 255),
                                barHeight: 6)
        view.addSubview(lungSlider!)
        
        lungSlider!.addTarget(self, action: #selector(lungSliderValueChanged), for: .valueChanged)
        lungSlider!.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        lungSlider!.addTarget(self, action: #selector(sliderTouchAway), for: .touchUpInside)
        lungSlider!.addTarget(self, action: #selector(sliderTouchAway), for: .touchUpOutside)
        //需要先对横向的slider进行autolayout
        lungSlider!.snp.makeConstraints({(maker) in
            maker.centerX.equalTo(aboveSlider)
            maker.centerY.equalTo(lungView)
            maker.width.equalTo(CTViewLen * 0.84)
        })
        lungSlider!.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
        
        //MARK: 虚线绘制
        if ctGroup.images.count > 1{
            dottedLine = drawADottedLine(viewWidth: Int(CTViewLen + view.frame.width * 0.06), viewHeight: 20, lineWidth: 2, lineColor: #colorLiteral(red: 1, green: 0.3803921569, blue: 0.3803921569, alpha: 1), filledWidth: 8, clearedWidth: 3)
            self.view.addSubview(dottedLine!)
            //获取thumb相对顶端的偏移量
            let trackRect = lungSlider!.trackRect(forBounds: lungSlider!.bounds)
            let thumbRect = lungSlider!.thumbRect(forBounds: lungSlider!.bounds, trackRect: trackRect, value: lungSlider!.value)
            dottedLine!.snp.makeConstraints({(maker) in
                maker.centerX.equalTo(lungView).offset(view.frame.width * 0.03)
                maker.centerY.equalTo(lungView.snp.top).offset(CTViewLen * 0.08 + lungSlider!.barHeight / 2 + thumbRect.origin.x)
            })
            dottedLine!.alpha = 0.39
        }
        
        if let prectGroup = prectGroup{
            prectView = SingleCTView(frame: CGRect(x: 0, y: 0, width: CTViewLen, height: CTViewLen * 1.12), ctgroup: prectGroup)
            view.addSubview(prectView!)
            prectView!.snp.makeConstraints { maker in
                maker.centerX.equalTo(lungView)
                maker.centerY.equalTo(lungView)
                maker.width.equalTo(CTViewLen)
                maker.height.equalTo(CTViewLen * 1.12)
            }
            prectView!.alpha = mode == BrowseMode.album ? 0 : 1
            
            //MARK: 下方slider初始化
            var focusMarkSet1 = Set<Int>()
            for (i, image) in prectGroup.images.enumerated(){
                if let rawAreaRatio = image.infoDict.object(forKey: "ratio") as? Double{
                    //areaRatio不为0
                    if abs(rawAreaRatio - 0) > 10e-5{
                        focusMarkSet1.insert(i)
                    }
                }
            }
            underSlider = MarkSlider(frame: CGRect(x: 0, y: 0, width: CTViewLen, height: 0),
                                     startPos: 10,
                                     endPos: 90,
                                     depthArr: preDepthArr[0..<prectGroup.images.count],
                                     focusIndexMark: focusMarkSet1,
                                     leftBarColor: UIColor(red: 196, green: 220, blue: 255),
                                     rightBarColor: #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1),
                                     barHeight: 6)
            view.addSubview(underSlider!)
            underSlider!.setThumbImage(UIImage(named: "thumb1"), for: .normal)
            
            underSlider!.addTarget(self, action: #selector(underSliderValueChanged), for: .valueChanged)
            underSlider!.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
            underSlider!.addTarget(self, action: #selector(sliderTouchAway), for: .touchUpInside)
            underSlider!.addTarget(self, action: #selector(sliderTouchAway), for: .touchUpOutside)
            //需要先对横向的slider进行autolayout
            underSlider!.snp.makeConstraints({(maker) in
                maker.centerX.equalTo(aboveSlider)
                maker.centerY.equalTo(prectView!.snp.centerY).offset(-CTViewLen * 0.03)
                maker.width.equalTo(CTViewLen)
            })
            underSlider!.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
            underSlider!.alpha = mode == BrowseMode.album ? 0 : 1
            
        }
        
        if mode == BrowseMode.contrast{
            dottedLine?.alpha = 0
            lungView?.alpha = 0
            lungSlider?.alpha = 0
        }
            
    }
    
    @objc private func back(){
        timer?.invalidate()
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:模式切换
    @objc private func modeSwitch(){
        if mode == BrowseMode.album{
            mode = .contrast
            titleLbl.text = "对比分析"
            modeSwitchBtn?.setBackgroundImage(UIImage(named: "contrastCancel"), for: .normal)
            aboveSliderValueChanged()
            UIView.animate(withDuration: 0.7){[unowned self] in
                self.prectView?.alpha = 1
                self.underSlider?.alpha = 1
                self.dottedLine?.alpha = 0
                self.lungView?.alpha = 0
                self.lungSlider?.alpha = 0
            }
            
        } else{
            mode = .album
            titleLbl.text = "深度浏览"
            modeSwitchBtn?.setBackgroundImage(UIImage(named: "contrastLast"), for: .normal)
            aboveSliderValueChanged()
            UIView.animate(withDuration: 0.7){[unowned self] in
                self.prectView?.alpha = 0
                self.underSlider?.alpha = 0
                self.dottedLine?.alpha = 0.3
                self.lungView?.alpha = 1
                self.lungSlider?.alpha = 1
            }
            
        }
    }
    
//    @objc private func runBtnTouchDown(){
//        runBtn.layer.shadowOpacity = 0.8
//    }
    
    @objc private func runBtnClicked(){
        runBtn.tag = runBtn.tag == PLAYING ? NOT_PLAYING : PLAYING
//        runBtn.layer.shadowOpacity = runBtn.tag == PLAYING ? 0.7 : 0
        let imageName = runBtn.tag == PLAYING ? "stop" : "play"
        runBtn.setBackgroundImage(UIImage(named: imageName), for: .normal)
        
        if runBtn.tag == NOT_PLAYING{
            timer?.invalidate()
        } else{
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(animating), userInfo: nil, repeats: true)
        }
        aboveSlider.isEnabled.toggle()
        lungSlider?.isEnabled.toggle()
        underSlider?.isEnabled.toggle()
    }
    
    //MARK:播放图片
    @objc private func animating(){
        ctView.curIndex = (ctView.curIndex + 1) % ctGroup.images.count
        aboveSlider.value = Float(aboveSlider.markPositions[ctView.curIndex])
        if mode == BrowseMode.album{
            lungSlider?.value = Float(lungSlider!.markPositions[ctView.curIndex])
            let trackRect = lungSlider!.trackRect(forBounds: lungSlider!.bounds)
            let thumbRect = lungSlider!.thumbRect(forBounds: lungSlider!.bounds, trackRect: trackRect, value: lungSlider!.value)
            dottedLine?.snp.updateConstraints({(maker) in
                maker.centerY.equalTo(lungView!.snp.top).offset(CTViewLen * 0.08 + lungSlider!.barHeight / 2 + thumbRect.origin.x)
            })
        } else if let prectView = prectView, let underSlider = underSlider{
            prectView.curIndex = (prectView.curIndex + 1) % ctGroup.images.count
            underSlider.value = Float(underSlider.markPositions[prectView.curIndex])
        }
    }
    
    @objc private func markSwitch(){
        let imageName = ctView.isOrigin ? "mark_gray" : "mark_green"
        markBtn.setBackgroundImage(UIImage(named: imageName), for: .normal)
        ctView.isOrigin.toggle()
        prectView?.isOrigin.toggle()
    }
    
    // MARK: 上方slider滑动
    @objc private func aboveSliderValueChanged(){
        guard !aboveSlider.markPositions.isEmpty else{
            return
        }
        let value = CGFloat(aboveSlider.value), curIndex = ctView.curIndex
        /// 相邻curIndex对应的pos在阈值范围内则切换图片
        let threshHold: CGFloat = 1 / aboveSlider.frame.width / 10
        /* Slider防止跳进的算法，先从curIndex的左右两点找，若不在范围内可能是在curIndex附近，也可能在更远的点，近邻遍历查找 */
        /* 如果时间复杂度过高会导致slider卡顿，所以在xxxValueChanged函数内的语句尽量控制在O(1) */
        //往前看
        if curIndex != 0 {
            if abs(aboveSlider.markPositions[curIndex - 1] - value) <= threshHold{
                ctView.curIndex = curIndex - 1
            }
            else if value < aboveSlider.markPositions[curIndex - 1]{
                var i: Int = 2
                while curIndex - i != -1 && value <= aboveSlider.markPositions[curIndex - i]{
                    i += 1
                }
                ctView.curIndex = curIndex - i + 1
            }
        }
        //往后看
        if curIndex != aboveSlider.markPositions.count - 1{
            if abs(aboveSlider.markPositions[curIndex + 1] - value) <= threshHold{
                ctView.curIndex = curIndex + 1
            }
            else if value > aboveSlider.markPositions[curIndex + 1]{
                var i: Int = 2
                while curIndex + i != aboveSlider.markPositions.count && value >= aboveSlider.markPositions[curIndex + i]{
                    i += 1
                }
                ctView.curIndex = curIndex + i - 1
            }
        }
        
        if mode == BrowseMode.album{
            //按比例联动lungSlider
            let start = CGFloat(aboveSlider.startPos), start1 = CGFloat(lungSlider!.startPos)
            let aboveRatio:CGFloat = (100 * value - start) / (CGFloat(aboveSlider.endPos) - start)
            let step1 = CGFloat(lungSlider!.endPos) - start1
            lungSlider?.value = Float(aboveRatio * step1 + start1) / 100
            
            let trackRect = lungSlider!.trackRect(forBounds: lungSlider!.bounds)
            let thumbRect = lungSlider!.thumbRect(forBounds: lungSlider!.bounds, trackRect: trackRect, value: lungSlider!.value)
            dottedLine?.snp.updateConstraints({(maker) in
                maker.centerY.equalTo(lungView!.snp.top).offset(CTViewLen * 0.08 + lungSlider!.barHeight / 2 + thumbRect.origin.x)
            })
        } else{
            if prectView!.curIndex != ctView.curIndex{
                prectView!.curIndex = ctView.curIndex
            }
            underSlider!.value = Float(underSlider!.markPositions[prectView!.curIndex])
        }
    }
    
    // MARK: 下方slider滑动
    @objc private func lungSliderValueChanged(){
        guard !lungSlider!.markPositions.isEmpty else{
            return
        }
        let value = CGFloat(lungSlider!.value), curIndex = ctView.curIndex
        /// 相邻curIndex对应的pos在阈值范围内则切换图片
        let threshHold: CGFloat = 1 / lungSlider!.frame.width / 10

        //往前看
        if curIndex != 0 {
            if abs(lungSlider!.markPositions[curIndex - 1] - value) <= threshHold{
                ctView.curIndex = curIndex - 1
            }
            else if value < lungSlider!.markPositions[curIndex - 1]{
                var i: Int = 2
                while curIndex - i != -1 && value <= lungSlider!.markPositions[curIndex - i]{
                    i += 1
                }
                ctView.curIndex = curIndex - i + 1
            }
        }
        //往后看
        if curIndex != lungSlider!.markPositions.count - 1{
            if abs(lungSlider!.markPositions[curIndex + 1] - value) <= threshHold{
                ctView.curIndex = curIndex + 1
            }
            else if value > lungSlider!.markPositions[curIndex + 1]{
                var i: Int = 2
                while curIndex + i != lungSlider!.markPositions.count && value >= lungSlider!.markPositions[curIndex + i]{
                    i += 1
                }
                ctView.curIndex = curIndex + i - 1
            }
        }
        
        //按比例联动aboveSlider
        let start = CGFloat(lungSlider!.startPos), start1 = CGFloat(aboveSlider.startPos)
        let aboveRatio:CGFloat = (100 * value - start) / (CGFloat(lungSlider!.endPos) - start)
        let step1 = CGFloat(aboveSlider.endPos) - start1
        aboveSlider.value = Float(aboveRatio * step1 + start1) / 100
        
        let trackRect = lungSlider!.trackRect(forBounds: lungSlider!.bounds)
        let thumbRect = lungSlider!.thumbRect(forBounds: lungSlider!.bounds, trackRect: trackRect, value: lungSlider!.value)
        dottedLine?.snp.updateConstraints({(maker) in
            maker.centerY.equalTo(lungView.snp.top).offset(CTViewLen * 0.08 + lungSlider!.barHeight / 2 + thumbRect.origin.x)
        })
    }
    
    // MARK: 下方slider滑动
    @objc private func underSliderValueChanged(){
        if let underSlider = underSlider, let prectView = prectView{
            let value = CGFloat(underSlider.value), curIndex = prectView.curIndex
            let threshHold: CGFloat = 1 / underSlider.frame.width / 10
            //往前看
            if curIndex != 0 {
                if abs(underSlider.markPositions[curIndex - 1] - value) <= threshHold{
                    prectView.curIndex = curIndex - 1
                }
                else if value < underSlider.markPositions[curIndex - 1]{
                    var i: Int = 2
                    while curIndex - i != -1 && value <= underSlider.markPositions[curIndex - i]{
                        i += 1
                    }
                    prectView.curIndex = curIndex - i + 1
                }
            }
            //往后看
            if curIndex != underSlider.markPositions.count - 1{
                if abs(underSlider.markPositions[curIndex + 1] - value) <= threshHold{
                    prectView.curIndex = curIndex + 1
                }
                else if value > underSlider.markPositions[curIndex + 1]{
                    var i: Int = 2
                    while curIndex + i != underSlider.markPositions.count && value >= underSlider.markPositions[curIndex + i]{
                        i += 1
                    }
                    prectView.curIndex = curIndex + i - 1
                }
            }

            if ctView.curIndex != prectView.curIndex{
                ctView.curIndex = prectView.curIndex
            }
            aboveSlider.value = Float(aboveSlider.markPositions[ctView.curIndex])
        }
    }
    
    // MARK: slider触碰
    @objc private func sliderTouchDown(){
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        if mode == BrowseMode.album{
            UIView.animate(withDuration: 0.4){[weak self] in
                self?.dottedLine?.alpha = 1
            }
        }
    }
    
    // MARK: slider抬起
    @objc private func sliderTouchAway(){
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
        if mode == BrowseMode.album{
            UIView.animate(withDuration: 0.4){[weak self] in
                self?.dottedLine?.alpha = 0.3
            }
        }
    }
}
