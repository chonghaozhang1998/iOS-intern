//
//  ShowPageCell.swift
//  ShowPageViewcontroller
//
//  Created by ZouYa on 2020/10/12.
//  Copyright © 2020 ZouYa. All rights reserved.
//

import UIKit

var headStateArr: [Bool] = []

class ShowRecordViewController: UIViewController{
    
    let layout = UICollectionViewFlowLayout()
    let itemSize = (UIScreen.main.bounds.width - 40) / 3
    
    var collectionView: UICollectionView!
    var moreItem = UIBarButtonItem()
    var popoverViewController: PopoverViewController!
    var bottomView:RecordBottomView?
    
    var selectedIndexes: [IndexPath] = []
    
    //从文件中读取相关数据进行设置
    var imageGroups: Array<CTImageGroup>!
    var numberOfSection = 0  //根据日期的数量创建分区数
    var numberOfItemsInSection : [Int] = []  //根据每个日期下图片的数量创建cell的数目
    var dateArr : [String] = [] //传入日期数组
    var arrayOfImageArray : [[UIImage]] = [] //传入每一组图片
    
    //判断是否为对比模式
    var isInComparison = false
    /// 判断是否为分享模式
    var isSharing = false
    
    // 显示浏览界面底部的图册以及照片总数
    var bottomLabel = UILabel()
    var bottomLine = UIView()
    var bottomUIView = UIView()
    var selectedDateInComparison:[(Int16, Int8, Int8)] = []

    init(){
        super.init(nibName:nil, bundle:nil)

        self.title = "历史记录"
        
        loadFiles()
        //更多、取消
        moreItem = UIBarButtonItem(image: UIImage(named: "more"), style: .plain, target: self, action: #selector(moreButtonClicked))
        self.navigationItem.rightBarButtonItem = moreItem
        
        popoverViewController = PopoverViewController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectItemsInSection(note:)), name: .init("allSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deselectSection(note:)), name: .init("comparison"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(browseAlbum(note:)), name: .init("albumBrowse"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()

        // 添加底部的UIView
        setupBottomUIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    func loadFiles(){
        sem.wait()
        //从本地写
        imageGroups = DocumentsManager.default.getCTImageGroups()
        
        numberOfSection = imageGroups.count
        for group in imageGroups{
            dateArr.append(group.date())
            numberOfItemsInSection.append(group.images.count)
            let uiimageArr = group.images.map { ctimage -> UIImage in
                return UIImage(contentsOfFile: ctimage.tag.absoluteString)!
            }
            arrayOfImageArray.append(uiimageArr)
        }
        headStateArr = [Bool](repeating: false, count: numberOfSection)
        sem.signal()
    }
    
    func setupCollectionView(){
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: itemSize, height: itemSize + 20/*字体*/)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 10
        //MARK:定义头尾视图宽高
        layout.headerReferenceSize = CGSize(width: screen_width, height: 50)
        layout.footerReferenceSize = CGSize(width: screen_width, height: 40)
        
        let bottomHeight = 50 + view.safeAreaInsets.bottom
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: screen_width, height: numberOfSection == 0 ? screen_height: screen_height - bottomHeight), collectionViewLayout: layout)
        
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ShowRecordCollectionViewCell.self, forCellWithReuseIdentifier: ShowRecordCollectionViewCell.Id)
        collectionView.register(ShowRecordCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ShowRecordCollectionReusableView.Id)
        collectionView.register(ShowRecordCollectionReusableFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: ShowRecordCollectionReusableFooterView.Id)
        
        collectionView.allowsMultipleSelection = false
        collectionView.allowsSelection = true
        collectionView.contentSize = CGSize(width: screen_width, height: 1600)
        
    }
    
    func setupBottomUIView() {
        guard numberOfSection != 0 else {
            return
        }
        
        let bottomHeight = 50 + heightOfAddtionalFooter
        bottomUIView.frame = CGRect(x: 0, y: screen_height - bottomHeight, width: screen_width, height: bottomHeight)
        bottomUIView.backgroundColor = .white
        view.addSubview(bottomUIView)
        
        let numberOfPhotos = numberOfItemsInSection.reduce(0, +)
        bottomLabel.font = .systemFont(ofSize: 16)
        bottomLabel.text = "\(numberOfPhotos)张照片、\(numberOfSection)个图册"
        bottomLabel.textColor = .black
        bottomUIView.addSubview(bottomLabel)
        bottomLabel.snp.makeConstraints{make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
                .offset(-heightOfAddtionalFooter / 2)
        }
//
        
        bottomLine.frame = CGRect(x: 0, y: 0, width: screen_width, height: 0.8)
        bottomLine.backgroundColor = #colorLiteral(red: 0.89826864, green: 0.89826864, blue: 0.89826864, alpha: 1)
        bottomUIView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints{make in
            make.top.equalTo(bottomUIView)
            make.height.equalTo(0.8)
            make.width.equalTo(bottomUIView)
        }
        
    }
    
    //MARK:选中头部
    @objc func selectItemsInSection(note: Notification) {
        guard let info = note.userInfo?["allSelected"], let tag = note.userInfo?["section"] else { return }
        let allSelected = info as! Bool
        let section = tag as! Int
        ///该分组的相册数
        let num = collectionView.numberOfItems(inSection: section)
        for index in 0..<num {
            let indexPath = IndexPath(item: index, section: section)
            
            if allSelected {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            } else {
                collectionView.deselectItem(at: indexPath, animated: false)
            }
        }
        //头部全部选中连带全选按钮的切换
        switchAllSelectedBtn()
        switchDeleteBtn()
        
        // 更新底部显示的选中的图册及照片
        updateNumberOfSelectedItemsInBottomView()
    }
    
    //MARK:对比模式反选头部
    @objc func deselectSection(note: Notification) {
        guard let num = note.userInfo?["selectedNum"] as? Int else { return }
//        let index = note.userInfo?["section"],
        if num < 1 || num == 1 && isInComparison{
            bottomView?.confirmBtn.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            bottomView?.confirmBtn.isEnabled = false
        }
        else{
            guard let index = note.userInfo?["section"] else { return }
            if num > 2{
                let head = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: index as! Int)) as! ShowRecordCollectionReusableView
                head.imageView.image = UIImage(named: "checkboxEmpty.png")
            }
            else{
                bottomView?.confirmBtn.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                bottomView?.confirmBtn.isEnabled = true
            }
        }
        // 对比模式下展示选中的日期
        if num == 0 {
            bottomLabel.text = "未选择日期"
            selectedDateInComparison.removeAll()
        }
        
        let section = note.userInfo!["section"] as! Int
        let selectingDate = (imageGroups[section].year, imageGroups[section].month, imageGroups[section].day)
        if num == 1 {
            if selectedDateInComparison.contains(where: {$0 == selectingDate}) {
                selectedDateInComparison.removeAll(where: {$0 == selectingDate})
            } else {
                selectedDateInComparison.append(selectingDate)
            }
            let month = selectedDateInComparison[0].1
            let day = selectedDateInComparison[0].2
            if isInComparison{
                bottomLabel.text = "已选择\(month)月\(day)日，还需再选中一个图集"
            } else{
                bottomLabel.text = "已选择\(month)月\(day)日"
            }
        }
        
        if num == 2 {
            selectedDateInComparison.append(selectingDate)
            selectedDateInComparison.sort{(first, second) -> Bool in
                if first.0 > second.0 { // 比较年
                    return true
                } else if first.0 < second.0 {
                    return false
                } else {
                    if first.1 > second.1 { // 比较月
                        return true
                    } else if first.1 < second.1 {
                        return false
                    } else { // 比较日
                        if first.2 > second.2 {
                            return true
                        } else if first.2 < second.2 {
                            return false
                        } else {
                            return true
                        }
                    }
                }
            }
            bottomLabel.text = "已选择"
            for (index, item) in selectedDateInComparison.enumerated() {
                bottomLabel.text!.append("\(item.1)月\(item.2)日")
                if (index + 1) != selectedDateInComparison.count {
                    bottomLabel.text!.append("、")
                }
            }
        }
    }
    
    //MARK:进入当日浏览界面
    @objc private func browseAlbum(note: Notification){
        guard let section = note.userInfo?["section"] as? Int else { return }
        print("选中第\(section)个section")
        let browseVC = BrowseViewController(mode: .album, group: imageGroups[section], preGroup: section == numberOfSection - 1 ? nil : imageGroups[section+1])
        browseVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(browseVC, animated: true)
    }
    
    //MARK:全选
    @objc func selectAllItemsInPage(){
        bottomView?.bottomSelectButton.isSelected.toggle()
        if bottomView!.bottomSelectButton.isSelected{
            bottomView?.bottomSelectButton.setImage(UIImage(named: "checkboxChoosed"), for: .normal)
        }else{
            bottomView?.bottomSelectButton.setImage(UIImage(named: "checkboxEmpty"), for: .normal)
        }
        
        if bottomView!.bottomSelectButton.isSelected {
//        if bottomView!.selectBtn.isSelected {
            headStateArr = [Bool].init(repeating: true, count: numberOfSection)
            for section in 0..<numberOfSection{
                if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section)) as? ShowRecordCollectionReusableView{
                    header.imageView.image = UIImage(named: "checkboxChoosed.png")
                    header.isAllSelectedInSection = true    //头视图的isAllSelectedInSection属性用来判断是否全选了
                }
                //全选item
                for i in 0..<collectionView.numberOfItems(inSection: section){
                    let indexPath = IndexPath(item: i, section: section)
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
                }
            }
        }else{
            headStateArr = [Bool].init(repeating: false, count: numberOfSection)
            for section in 0..<numberOfSection{
                if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section)) as? ShowRecordCollectionReusableView{
                    header.imageView.image = UIImage(named: "checkboxEmpty.png")
                    header.isAllSelectedInSection = false    //头视图的isAllSelectedInSection属性用来判断是否全选了
                }
                //全反选item
                for i in 0..<collectionView.numberOfItems(inSection: section){
                    let indexPath = IndexPath(item: i, section: section)
                    collectionView.deselectItem(at: indexPath, animated: false)
                }
            }
        }
        switchDeleteBtn()
        
        // 更新底部显示的选中的图册及照片
        updateNumberOfSelectedItemsInBottomView()
    }
    
    
    //MARK:点击删除或对比，弹出多选框，点击取消收回
    private func updateUserInterface() {
        if isEditing || isInComparison || isSharing{
            ///底部面板的高度
            let bottomHeight = 58 + heightOfAddtionalFooter
            bottomView = RecordBottomView(frame: CGRect(x: 0, y: screen_height, width: screen_width, height: bottomHeight), delete: isEditing, compare: isInComparison, share: isSharing)
            bottomView?.confirmBtn.isEnabled = !(collectionView.indexPathsForSelectedItems!.count == 0)
            if isEditing {
                bottomView?.confirmBtn.addTarget(self, action: #selector(deleteConfirm), for: .touchDown)
                bottomView?.bottomSelectButton.addTarget(self, action: #selector(selectAllItemsInPage), for: .touchDown)
                
            }else if isInComparison{
                bottomView?.confirmBtn.addTarget(self, action: #selector(compareConfirm), for: .touchDown)
            }else if isSharing{
                bottomView?.confirmBtn.addTarget(self, action: #selector(shareConfirm), for: .touchDown)
            }
            self.view.addSubview(bottomView!)
            
            let nowItem = self.navigationItem.rightBarButtonItem
            nowItem?.image = nil
            nowItem?.title = "取消"
        }else{
            let nowItem = self.navigationItem.rightBarButtonItem
            nowItem?.title = nil
            nowItem?.image = UIImage(named: "more")
        }
        
        // 设置 bottomLabel 以及 bottomUIView
        let bottomHeight = 50 + heightOfAddtionalFooter
        if isInComparison || isSharing {
            print("comparison/sharing interface")
            bottomLabel.text = "未选择日期"
            UIView.animate(withDuration: 0.2) {[unowned self] in
                self.bottomView?.center.y -= bottomHeight + 8
                self.bottomUIView.frame = CGRect(x: 0, y: screen_height - bottomHeight - 58, width: screen_width, height: bottomHeight)
                self.collectionView.frame = CGRect(x: 0, y: 0, width: screen_width, height: screen_height - bottomHeight - 50)
            }
        } else if isEditing {
            print("editing interface")
            UIView.animate(withDuration: 0.2) {[unowned self] in
                self.bottomView?.center.y -= bottomHeight + 8
                self.bottomUIView.frame = CGRect(x: 0, y: screen_height - bottomHeight - 58, width: screen_width, height: bottomHeight)
                self.collectionView.frame = CGRect(x: 0, y: 0, width: screen_width, height: screen_height - bottomHeight - 50)
            } completion: {[unowned self] _ in
                self.bottomLabel.text = "\(numberOfItemsInSection.reduce(0, +))张照片、\(numberOfSection)个图册"
            }
        } else {
            print("cancel")
            // 取消状态下清空 对比状态下选中的数组
            selectedDateInComparison.removeAll()
            
            self.collectionView.frame = CGRect(x: 0, y: 0, width: screen_width, height: screen_height - bottomHeight)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.13) {
                //动态滑下
                UIView.animate(withDuration: 0.2) {[unowned self] in
                    bottomUIView.frame = CGRect(x: 0, y: screen_height - bottomHeight, width: screen_width, height: bottomHeight)
                    if !isEditing && !isInComparison{
                        self.bottomView?.center.y += bottomHeight
                    }
                } completion: { _ in
                    self.bottomLabel.text = "\(self.numberOfItemsInSection.reduce(0, +))张照片、\(self.numberOfSection)个图册"
                    self.bottomView?.removeFromSuperview()
                }
            }
        }
    }
    
    //改变item的状态
    func clearSelectedItems(animated: Bool) {
        for indexPath in collectionView.indexPathsForSelectedItems!{
            DispatchQueue.main.async {[unowned self] in
                self.collectionView.deselectItem(at: indexPath, animated: animated)
            }
        }
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
    
    //MARK:弹出和收回选框
    override func setEditing(_ editing: Bool, animated: Bool) {
        guard isEditing != editing else {
            return
        }
        super.setEditing(editing, animated: animated)
        collectionView.allowsMultipleSelection = editing    //改变cell的showSelectionIcons状态，让cell改变状态

        clearSelectedItems(animated: true)  //每一次改变编辑状态时，都把已选改为不选
        updateUserInterface()
    }
    
    //MARK:上方对比
    @objc private func compareBtnClicked(){
        isInComparison = true
        updateUserInterface()
        NotificationCenter.default.post(name: .init("compare"), object: nil, userInfo: ["isCompare" : isInComparison])
    }
    
    //MARK:上方分享
    @objc private func shareBtnClicked(){
        isSharing = true
        updateUserInterface()
        NotificationCenter.default.post(name: .init("share"), object: nil, userInfo: ["isSharing" : isSharing])
    }
  
    // MARK:上方删除
    @objc private func deleteOperation(){
        if isEditing {
            if let selectItems = collectionView.indexPathsForSelectedItems {
                print("选中的item: ", selectItems)
            }
        } else {
            setEditing(!isEditing, animated: true)
            NotificationCenter.default.post(name: .init("edited"), object: nil, userInfo: ["isEdited": isEditing])
            
            headStateArr = [Bool](repeating: false, count: numberOfSection)
        }
    }
    
    //点击更多图标≡
    @objc private func moreButtonClicked(){
        if isEditing == false && isInComparison == false && isSharing == false{

            popoverViewController.deleteBtn.addTarget(self, action: #selector(deleteOperation), for: .touchUpInside)
            popoverViewController.compareBtn.addTarget(self, action: #selector(compareBtnClicked), for: .touchUpInside)
            popoverViewController.shareBtn.addTarget(self, action: #selector(shareBtnClicked), for: .touchUpInside)
            popoverViewController.preferredContentSize = CGSize(width: screen_width / 4, height: 103)
            popoverViewController.modalPresentationStyle = .popover
            popoverViewController.popoverPresentationController?.sourceView = self.view
            popoverViewController.popoverPresentationController?.permittedArrowDirections = .up
            popoverViewController.popoverPresentationController?.delegate = self
            self.present(popoverViewController, animated: true, completion: nil)
        }else if isEditing {
            headStateArr = [Bool](repeating: false, count: numberOfSection)
            setEditing(!isEditing, animated: true)
            //恢复所有相册为未选中
            deselectAllHeaders()
            
            NotificationCenter.default.post(name: .init("edited"), object: nil, userInfo: ["isEdited": isEditing])
            bottomView?.bottomSelectButton.setImage(UIImage(named: "checkboxEmpty"), for: .normal)
        }
        //点击取消
        else if isInComparison{
            isInComparison = false
            updateUserInterface()
            NotificationCenter.default.post(name: .init("compare"), object: nil, userInfo: ["isCompare" : isInComparison])
            headStateQueue.removeAll()
        }
        else if isSharing{
            isSharing = false
            updateUserInterface()
            NotificationCenter.default.post(name: .init("share"), object: nil, userInfo: ["isSharing" : isSharing])
            headStateQueue.removeAll()
        }
        
    }
    
    //MARK: 下方对比
    @objc private func compareConfirm(){
        headStateQueue.sort()
        print("对比的分组下标数组：\(headStateQueue)")
        let browseVC = BrowseViewController(mode: .contrast, group: imageGroups[headStateQueue[0]], preGroup: imageGroups[headStateQueue[1]])
        browseVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(browseVC, animated: true)
        
        headStateQueue.removeAll()
        isInComparison = false
        //给每个header发消息，隐藏掉选框
        NotificationCenter.default.post(name: .init("compare"), object: nil, userInfo: ["isCompare" : isInComparison])
        updateUserInterface()
    }

    //MARK: 下方分享
    @objc private func shareConfirm(){
        print("分享的分组下标数组：\(headStateQueue)")
        //创建剪切板
        let pb = UIPasteboard.general
        switch headStateQueue.first!{
        case 1:
            pb.string = "https://shimo.im/docs/QhgTdV8tTVrCQ9vP/ 《口袋CT》，点击链接后在 Safari 中打开"
        case 2:
            pb.string = "https://shimo.im/docs/gyGq3pQ6jVY9Y8YK/ 《口袋CT》，点击链接后在 Safari 中打开"
        //包括case 0的默认值
        default:
            pb.string = "https://shimo.im/docs/hQkkqYDY9QHqCjgd/ 《口袋CT》，点击链接后在 Safari 中打开"
        }
        
        //创建弹出框
        let alertController = UIAlertController(title: "提示\n", message: "你的分享链接已经复制到剪切板，请前往微信分享给好友", preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "点击前往", style: .default) { (action) in
            "weixin://".openAsUrl {
                print("未检测到微信app")
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
            print("取消")
        }
        alertController.addAction(sureAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
        headStateQueue.removeAll()
        isSharing = false
        //给每个header发消息，隐藏掉选框
        NotificationCenter.default.post(name: .init("share"), object: nil, userInfo: ["isSharing" : isSharing])
        updateUserInterface()
    }
    
    //MARK: 下方删除
    @objc private func deleteConfirm(){
        let alert = UIAlertController(title: "确认删除选中的图片？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认", style: .default){[unowned self]
            _ in self.deleteConfirmCheck()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel){
            _ in return
        })
        self.present(alert,animated: true, completion: nil)
    }
    
    @objc private func deleteConfirmCheck(){
        if var indexPaths = collectionView.indexPathsForSelectedItems{
            indexPaths.sort(by: >)
            print(indexPaths)
            for indexPath in indexPaths{
                arrayOfImageArray[indexPath.section].remove(at: indexPath.item)
                DocumentsManager.default.deleteImagesOfCTImage(imageGroups[indexPath.section].images.remove(at: indexPath.item))
                numberOfItemsInSection[indexPath.section] -= 1
            }
            var sectionToBeDeleted = Array<Int>()
            for i in stride(from: numberOfSection - 1, through: 0, by: -1){
                if arrayOfImageArray[i].isEmpty{
                    arrayOfImageArray.remove(at: i)
                    dateArr.remove(at: i)
                    numberOfItemsInSection.remove(at: i)
                    headStateArr.remove(at: i)
                    DocumentsManager.default.deleteDirectoryOfGroup(imageGroups.remove(at: i))
                    numberOfSection -= 1
                    sectionToBeDeleted.append(i)
                }
            }
//            print("删除后：",dateArr, numberOfItemsInSection, numberOfSection, "\n",indexPaths,"\n")
            UIView.performWithoutAnimation {
                collectionView.performBatchUpdates {
                    collectionView.deleteSections(IndexSet(sectionToBeDeleted))
                    collectionView.deleteItems(at: indexPaths)
                }completion: { [unowned self] (finished) in
                    UIView.performWithoutAnimation {
                        self.collectionView.reloadSections(IndexSet(Array(0..<numberOfSection)))
                    }
                }
            }
        }
        setEditing(!isEditing, animated: true)
        NotificationCenter.default.post(name: .init("edited"), object: nil, userInfo: ["isEdited": isEditing])
        //恢复未选中
        headStateArr = [Bool](repeating: false, count: numberOfSection)
        
        // 删除之后修改浏览界面底部栏的状态
        if numberOfItemsInSection.reduce(0, +) == 0 {
            bottomUIView.isHidden = true
            collectionView.frame = CGRect(x: 0, y: 0, width: screen_width, height: screen_height)
        } else {
            bottomLabel.text = "\(numberOfItemsInSection.reduce(0, +))张照片、\(numberOfSection)个图册"
        }
    }
}


extension ShowRecordViewController: UICollectionViewDelegate,UICollectionViewDataSource,UIPopoverPresentationControllerDelegate{
    
    //MARK:collectionView delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSection
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection[section]
    }
    
    //MARK:返回cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowRecordCollectionViewCell.Id, for: indexPath) as! ShowRecordCollectionViewCell
        cell.configCell(with: arrayOfImageArray[indexPath.section][indexPath.item], showSelectionIcons: collectionView.allowsMultipleSelection || headStateArr[indexPath.section], rawAreaRatio: imageGroups[indexPath.section].images[indexPath.item].infoDict.object(forKey: "ratio") as! Double)
        return cell
    }

    //MARK:返回header和footer
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ShowRecordCollectionReusableView.Id, for: indexPath) as! ShowRecordCollectionReusableView
            headerView.backgroundColor = .white
            headerView.configTime(with: dateArr[indexPath.section], indexPath: indexPath, isAllSelectedInSection: headStateArr[indexPath.section] || headStateQueue.contains(indexPath.section))
            headerView.isEdited = isEditing
            return headerView
        }
        else if kind == UICollectionView.elementKindSectionFooter{
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ShowRecordCollectionReusableFooterView.Id, for: indexPath) as! ShowRecordCollectionReusableFooterView
            //最后一个footer为白色
            footerView.backView.backgroundColor = (indexPath.section == numberOfSection - 1) ? .white : #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            return footerView
        }
        return UICollectionReusableView()
    }
    
    //MARK:点击item
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            //let AIResultPageVC = AIResultPageViewController()
            //AIResultPageVC.modalPresentationStyle = .fullScreen
            //self.present(AIResultPageVC, animated: true, completion: nil)
            
            if isEditing == false {
                print("点击位置: \(indexPath.section)节, \(indexPath.item)个")
                let ctimage = imageGroups[indexPath.section].images[indexPath.item]
                
                let displayVC = DisplayViewController(originImage: UIImage(contentsOfFile: ctimage.origin.absoluteString)!, capturesImage: UIImage(contentsOfFile: ctimage.tag.absoluteString)!, info: ctimage.infoDict)
                navigationController?.pushViewController(displayVC, animated: true)
    //            collectionView.deselectItem(at: indexPath, animated: false)
            } else {
                print("选择位置: \(indexPath.section)节, \(indexPath.item)个")
                if let indexes = collectionView.indexPathsForSelectedItems {
                    //判断这个section里是否全选了，如果是，则改变头视图
                    let indexNum = indexes.filter {$0.section == indexPath.section}.count
                    let num = collectionView.numberOfItems(inSection: indexPath.section)
                    if num == indexNum {
                        let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: indexPath.section)) as! ShowRecordCollectionReusableView
                        header.imageView.image = UIImage(named: "checkboxChoosed.png")
                        header.isAllSelectedInSection = true    //头视图的isAllSelectedInSection属性用来判断是否全选了
                        headStateArr[indexPath.section] = true
                    }
                }
                // 删除模式 + 选中的状态更新
                updateNumberOfSelectedItemsInBottomView()
            }
            //连带全选按钮
            switchAllSelectedBtn()
            if !isInComparison{
                switchDeleteBtn()
            }
        }

    //MARK:反选item
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("取消选择位置: \(indexPath.section)节, \(indexPath.item)个")
        let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: indexPath.section)) as? ShowRecordCollectionReusableView
        header?.imageView.image = UIImage(named: "checkboxEmpty.png")
        header?.isAllSelectedInSection = false
        headStateArr[indexPath.section] = false
        //全选按钮一定恢复未选中
        bottomView?.bottomSelectButton.isSelected = false
        bottomView?.bottomSelectButton.setImage(UIImage(named: "checkboxEmpty.png"), for: .normal)
//        bottomView?.selectBtn.isSelected = false
//        bottomView?.selectBtn.setImage(UIImage(named: "checkboxEmpty.png"), for: .normal)
        switchDeleteBtn()
        
        // 取消 + 删除模式下 更新
        updateNumberOfSelectedItemsInBottomView()
    }
    
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //MARK:popover delegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem
    }
    
    
    /// 连带全选按钮
    private func switchAllSelectedBtn(){
        guard bottomView != nil else {
            return
        }
        bottomView?.bottomSelectButton.isSelected = headStateArr.filter({
//        bottomView.selectBtn.isSelected = headStateArr.filter({
            $0 == true
        }).count == headStateArr.count
        if bottomView!.bottomSelectButton.isSelected{
            bottomView?.bottomSelectButton.setImage(UIImage(named: "checkboxChoosed.png"), for: .normal)
        }else{
            bottomView?.bottomSelectButton.setImage(UIImage(named: "checkboxEmpty.png"), for: .normal)
        }
//        if bottomView.selectBtn.isSelected{
//            bottomView.selectBtn.setImage(UIImage(named: "checkboxChoosed.png"), for: .normal)
//        }else{
//            bottomView.selectBtn.setImage(UIImage(named: "checkboxEmpty.png"), for: .normal)
//        }
    }
    
    
    /// 未选中任何图册则禁用确认按钮
    private func switchDeleteBtn(){
        if collectionView.indexPathsForSelectedItems!.count == 0{
            bottomView?.confirmBtn.isEnabled = false
//            bottomView?.confirmBtn.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
        else{
            bottomView?.confirmBtn.isEnabled = true
//            bottomView?.confirmBtn.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        }
    }
    
    /// 恢复所有头部视图为未选中状态
    private func deselectAllHeaders(){
        //恢复所有相册为未选中
        for i in 0..<collectionView.numberOfSections{
            if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: i)) as? ShowRecordCollectionReusableView{
                header.isAllSelectedInSection = false
            }
            //section下的相册也恢复未选中
            for j in 0..<collectionView.numberOfItems(inSection: i){
                collectionView.deselectItem(at: IndexPath(item: j, section: i), animated: false)
            }
        }
    }
    
    
    private func updateNumberOfSelectedItemsInBottomView() {
        // 删除模式下设置选中的 图册 以及 图片
        var numberOfSelectedSections = 0
        var numberOfSelectedPhotos = 0
        var selectedSections:[Int] = []
        if let indexPaths = collectionView.indexPathsForSelectedItems{
            for indexPath in indexPaths {
                if !selectedSections.contains(where: {$0 == indexPath.section}){
                    selectedSections.append(indexPath.section)
                }
                numberOfSelectedPhotos += 1
            }
        }
        numberOfSelectedSections = selectedSections.count
        if numberOfSelectedPhotos == 0 && numberOfSelectedSections == 0 {
            bottomView?.numberOfSelectedItems.text = "未选择照片及图册"
        } else {
            bottomView?.numberOfSelectedItems.text = "已选择\(numberOfSelectedPhotos)张照片 \(numberOfSelectedSections)个图册"
        }
    }
}

extension String {
    
    func openAsUrl(backAlert: @escaping () -> Void){
        let url = NSURL(string:self)
        if let resultUrl = url,UIApplication.shared.canOpenURL(resultUrl as URL){
            UIApplication.shared.open(resultUrl as URL, options: [:], completionHandler: nil)
        } else {
            backAlert()
        }
    }
    
}
