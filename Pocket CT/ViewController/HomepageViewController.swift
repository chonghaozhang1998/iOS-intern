//
//  ViewController.swift
//  Homepage
//
//  Created by chasingzch on 2020/10/27.
//

import UIKit
import SnapKit
import SwiftyGif
import AVKit

class HomepageViewController: UIViewController {
    
    // MARK: - 设置参数常量
    private let fontSize = CGFloat(11.5)
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    // MARK: - 设置控件
    private var recordButton: UIButton!
//    private var cameraButton: UIButton!
    private var cameraImageView: UIImageView!
    private var cameraShadowView: UIView!
    private var profileButton = UIButton()
    private var name = UILabel()
    private var arrowImage = UIImageView()
    private var scannerLabel = UILabel()
    private let pulsator = Pulsator()
    private var collectionView: UICollectionView!
    private var infoArray:[UIImage] = []
    private var pageControl: UIPageControl!
    private var autoScrollTimer:Timer?
    private var pulsatorTimer:Timer?
    
    /// 动画互斥变量
    private var arrowIsAnimating: Bool = false
    
    // 为了实现 collectionView 无限轮播设置的参数
    private var MaxSections = 3
    
    //VC
    private var photoVC:PhotoViewController!
    private var recordVC:ShowRecordViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = #colorLiteral(red: 0.9998885989, green: 1, blue: 0.9998806119, alpha: 1)
        
        //VC配置
        photoVC = PhotoViewController()
        photoVC.modalPresentationStyle = .fullScreen
        photoVC.cameraManager.stopRunning()
        for i in 0..<3 {
            infoArray.append(UIImage(named: "info\(i)")!)
        }
        setup()
        setupCollectionView()
        setupPageControl()
        setupAutoScrollTimer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    /// 后台挂起
    @objc private func applicationWillResignActive(){
        arrowIsAnimating = false
        pulsatorTimer?.invalidate()
        pulsatorTimer = nil
    }
    
    /// 后台唤醒
    @objc private func applicationDidBecomeActive(){
        if !arrowIsAnimating{
            arrowIsAnimating = true
            //校正中心点
            arrowImage.center.y = cameraImageView.frame.maxY - 30
            arrowImage.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.6, delay: 0, options: [.autoreverse, .repeat, .curveEaseOut, .beginFromCurrentState], animations: {
                self.arrowImage.center.y -= 15
            }, completion: nil)
        }
        if pulsatorTimer == nil{
            pulsatorTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(autoPulsate), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        //校正中心点
        arrowImage.center.y = cameraImageView.frame.maxY - 30
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {[unowned self] in
            //预加载，文件载入
            self.recordVC = ShowRecordViewController()
            self.recordVC.modalPresentationStyle = .fullScreen
            self.photoVC.cameraManager.stopRunning()
        }

        if !arrowIsAnimating{
            arrowIsAnimating = true
            //校正中心点
            arrowImage.center.y = cameraImageView.frame.maxY - 30
            UIView.animate(withDuration: 0.6, delay: 0, options: [.autoreverse, .repeat, .curveEaseOut], animations: {
                self.arrowImage.center.y -= 15
            }, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        arrowIsAnimating = false
        arrowImage.layer.removeAllAnimations()
        arrowImage.center.y += 15
    }
    
    func setup() {
        // 设置 profileButton
        self.title = "主页"
        self.view.addSubview(profileButton)
        profileButton.snp.makeConstraints{ maker in
            maker.top.equalToSuperview().offset(62)
            maker.left.equalTo(18)
        }
        profileButton.setImage(UIImage(named: "profileButton"), for: .normal)
        profileButton.addTarget(self, action: #selector(profileButtonClick), for: .touchUpInside)
        
        // 设置 name
        self.view.addSubview(name)
        name.snp.makeConstraints{ maker in
            maker.top.equalTo(profileButton.snp.top).offset(8)
            maker.left.equalTo(profileButton.snp.right).offset(12)
        }
        name.text = "张三"
        name.textColor = #colorLiteral(red: 0.1278046072, green: 0.6545203328, blue: 0.7996678948, alpha: 1)
        name.font = .systemFont(ofSize: 18)
        
        // 设置 historyButton
        recordButton = UIButton()
        self.view.addSubview(recordButton)
        recordButton.snp.makeConstraints{ maker in
            maker.top.equalTo(profileButton.snp.top)
            maker.right.equalTo(15)
            maker.width.equalTo(120)
            maker.height.equalTo(32)
        }
        recordButton.setImage(UIImage(named: "historyButton"), for: .normal)
        recordButton.addTarget(self, action: #selector(recordButtonClick), for: .touchUpInside)
        
        // 设置 cameraButton
        
        //加载gif
        do {
            let gif = try UIImage(gifName: "photo.gif", levelOfIntegrity: 0.8)
            cameraImageView = UIImageView(gifImage: gif, loopCount: -1)
            cameraImageView.isUserInteractionEnabled = true
            self.view.addSubview(cameraImageView)
            
//            cameraButton.setBackgroundImage(gif, for: .normal)
        } catch {
            print(error)
        }
//        cameraButton.setBackgroundImage(UIImage(named: "cameraButton"), for: .normal)
        cameraImageView.snp.makeConstraints{ maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview().offset(-78)
            maker.width.equalTo(self.view.frame.width * 0.7)
            maker.height.equalTo(self.view.frame.width * 0.7)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cameraViewTapped(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        cameraImageView.addGestureRecognizer(tapGestureRecognizer)
//        cameraImageView.addTarget(self, action: #selector(cameraButtonClick), for: .touchUpInside)
        //设置阴影310/600
        let scale: CGFloat = 0.7 * 310.0/600.0
        let width = view.frame.width * scale
        cameraShadowView = UIView()
        cameraShadowView.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        cameraShadowView.layer.cornerRadius = width/2
        cameraShadowView.layer.shadowColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1).cgColor
        cameraShadowView.layer.shadowOpacity = 0.4
        cameraShadowView.layer.shadowRadius = 10.0
        cameraShadowView.layer.shadowOffset = .init(width: 4.0, height: 4.0)
        view.insertSubview(cameraShadowView, belowSubview: cameraImageView)
        
        cameraShadowView.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview().offset(-83)
            maker.width.equalTo(view.frame.width*scale)
            maker.height.equalTo(view.frame.width*scale)
        }
        
        //设置脉冲层
        cameraImageView.layer.superlayer?.insertSublayer(pulsator, below: cameraImageView.layer)
        view.layer.layoutIfNeeded()
        pulsator.position = cameraImageView.layer.position
        pulsator.position.y -= 5
        pulsator.numPulse = 3
        pulsator.radius = view.frame.width * 0.55
        pulsator.animationDuration = 3.5
        pulsator.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.6549019608, blue: 0.8, alpha: 0.58)
        
        if pulsatorTimer == nil{
            pulsatorTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(autoPulsate), userInfo: nil, repeats: true)
        }
        pulsator.start()
        
        // 设置 arrow
        self.view.addSubview(arrowImage)
        arrowImage.snp.makeConstraints{ maker in
            maker.centerX.equalTo(cameraImageView)
            maker.bottom.equalTo(cameraImageView.snp.bottom).offset(-30 - 10)
        }
        arrowImage.image = UIImage(named: "arrow")
        
        // 设置 scannerLabel
        self.view.addSubview(scannerLabel)
        scannerLabel.snp.makeConstraints{maker in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(cameraImageView.snp.bottom).offset(-15)
        }
        scannerLabel.text = "拍照扫描"
        scannerLabel.textColor = #colorLiteral(red: 0.1278046072, green: 0.6545203328, blue: 0.7996678948, alpha: 1)
        scannerLabel.font = .systemFont(ofSize: 18)
    }
    
    @objc func profileButtonClick() {
        print("profileButtonClicked")
    }
    
    //MARK:点击历史记录
    @objc private func recordButtonClick() {
        navigationController?.pushViewController(recordVC, animated: true)
    }
    
    @objc private func cameraViewTapped(sender: UITapGestureRecognizer) {
        navigationController?.pushViewController(photoVC, animated: true)
    }
    
    
    func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 351, height: 127.5)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
//        flowLayout.sectionInset = sectionInsets
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.layer.cornerRadius = 7
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints {maker in
            maker.centerX.equalTo(self.view.snp.centerX)
            maker.bottom.equalTo(self.view).offset(-26.5)
            maker.left.equalTo(self.view.snp.centerX).offset(-175.5)
            maker.right.equalTo(self.view.snp.centerX).offset(175.5)
            maker.height.equalTo(127.5)
        }
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.ID)
    }
    
    func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = infoArray.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = #colorLiteral(red: 0.7781612277, green: 0.8361659646, blue: 0.9174571633, alpha: 1)
        pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.2579443753, green: 0.4595387578, blue: 0.7260489464, alpha: 1)
        self.view.addSubview(pageControl)
        pageControl.snp.makeConstraints{maker in
            maker.centerX.equalTo(self.view.snp.centerX)
            maker.bottom.equalTo(collectionView.snp.top).offset(-15)
        }
        pageControl.addTarget(self, action: #selector(updatePageControl), for: .valueChanged)
    }
    
    @objc private func updatePageControl() {
        collectionView.scrollToItem(at: IndexPath(item: pageControl.currentPage, section: self.collectionView.indexPathsForVisibleItems.last!.section),
                                    at: .centeredHorizontally, animated: true)
        self.autoScrollTimer!.invalidate()
        self.autoScrollTimer = nil
        setupAutoScrollTimer()
    }
    
    func setupAutoScrollTimer() {
        self.autoScrollTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
        RunLoop.current.add(self.autoScrollTimer!, forMode: .common)
    }
    
    @objc private func autoScroll() {
        let currentIndexPath = self.collectionView.indexPathsForVisibleItems.last!
        let middleIndexPath = IndexPath(item: currentIndexPath.item, section: MaxSections / 2)
        collectionView.scrollToItem(at: middleIndexPath, at: .centeredHorizontally, animated: false)
        
        var nextItem = middleIndexPath.item + 1
        var nextSection = middleIndexPath.section
        if nextItem == infoArray.count {
            nextItem = 0
            nextSection += 1
        }
        collectionView.scrollToItem(at: IndexPath(item: nextItem, section: nextSection),
                                    at: .centeredHorizontally, animated: true)
    }
    
    @objc private func autoPulsate(){
        pulsator.start()
    }
    
}
extension HomepageViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.ID, for: indexPath) as! CollectionViewCell
        cell.configCell(with: infoArray[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("点击位置:\(indexPath.section)section \(indexPath.item)item")
        switch indexPath.item {
        case 0, 1:
            //科普链接
            let webVC = WebViewController(urlString: indexPath.item == 0 ? "https://mp.weixin.qq.com/s/JgCMgEsAZkWqlLBYMiEbzA" : "https://mp.weixin.qq.com/s/jSic3cmv5xIMJtfz0OIQ0A", title: indexPath.item == 0 ? "AI与新冠CT" : "新冠肺炎与CT")
            webVC.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(webVC, animated: true)
            navigationController?.navigationBar.isHidden = false
            navigationController?.title = "AI与新冠CT"
        case 2:
            //一分钟视频
            let path = Bundle.main.path(forResource: "video", ofType: "mp4")!
            let fileUrl = URL(fileURLWithPath: path)
            let player = AVPlayer(url: fileUrl)
            let playerVC = AVPlayerViewController()
            playerVC.player = player
            self.present(playerVC, animated: true) {
                playerVC.player?.play()
            }
        default:
            print(indexPath.item)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.MaxSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.infoArray.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.x
        let page = contentOffset / scrollView.frame.size.width + (Int(contentOffset) % Int(scrollView.frame.size.width) == 0 ? 0 : 1)
        pageControl.currentPage = Int(page) % infoArray.count
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.autoScrollTimer?.invalidate()
        self.autoScrollTimer = nil
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.setupAutoScrollTimer()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.collectionView.scrollToItem(at: IndexPath(item: pageControl.currentPage, section: MaxSections / 2), at: .centeredHorizontally, animated: false)
    }
    
}

