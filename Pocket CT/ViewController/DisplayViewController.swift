//
//  ImageViewController.swift
//  CTDemo
//
//  Created by RodinYTY on 2020/10/28.
//

import UIKit
import Photos

/// 多线程
let sem = DispatchSemaphore(value: 1)

/// 单天展示界面
class DisplayViewController: UIViewController {
    var rect:CGRect!
    
    /// 是否从照相页面过来，需要提前标识
    var fromPhotoPage: Bool = false

    var zoomView: ZoomImageView!
    var showOrigin: Bool = false
    
    private var oriImage: UIImage?
    private var capturesImage: UIImage?
    private var info: NSMutableDictionary!
    
    private var backBtn: UIButton!
    private var contrastSwitch: UISwitch!
    
    //根据从哪里决定是否添加
    private var discardBtn: UIButton?
    private var againBtn: UIButton?

    
    // MARK: - 覆写init
    init(){
        super.init(nibName:nil, bundle:nil)
    }

    /// 便捷构造方法
    /// - Parameters:
    ///   - originImage: 原始图片
    ///   - capturesImage: 标识图片
    ///   - info: 识别信息字典
    convenience init(originImage: UIImage, capturesImage: UIImage, info: NSMutableDictionary){
        self.init()
        self.oriImage = originImage.resize(to: CGSize(width: 1600, height: 1600))
        self.capturesImage = capturesImage.resize(to: CGSize(width: 1600, height: 1600))
        self.info = info
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 界面
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "识别结果"
        configUI()
    }
    
    func configUI() {
        view.backgroundColor = .black
        zoomView = ZoomImageView(frame: view.bounds)
        zoomView.image = capturesImage
        zoomView.zoomMode = .fit
        zoomView.isUserInteractionEnabled = true
        zoomView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(albumSave)))
        view.addSubview(zoomView)
        
        backBtn = UIButton()
        view.addSubview(backBtn)
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backToHomepage), for: .touchUpInside)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 27),
            backBtn.widthAnchor.constraint(equalToConstant: 22),
            backBtn.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        //MARK:标签
        if let rawAreaRatio = info.object(forKey: "ratio") as? Double{
            let infoLbl = UILabel()
            infoLbl.font = .systemFont(ofSize: 18)
            infoLbl.textAlignment = .center
            if abs(rawAreaRatio - 0) <= 10e-5{
                let attri = NSMutableAttributedString(string: "病灶：0%")
                attri.addAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], range: NSRange(location: 0, length: 3))
                attri.addAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)], range: NSRange(location: 3, length: attri.length - 3))
                infoLbl.attributedText = attri
            }
            else{
                let attri = NSMutableAttributedString(string: "病灶：\(String (format:  "%.1f" , min(rawAreaRatio * 100 * 1.8, 95)))%")
                attri.addAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], range: NSRange(location: 0, length: 3))
                attri.addAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor: UIColor.red], range: NSRange(location: 3, length: attri.length - 3))
                infoLbl.attributedText = attri
            }
            view.addSubview(infoLbl)
            infoLbl.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                infoLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                infoLbl.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor),
                infoLbl.widthAnchor.constraint(equalToConstant: 100),
                infoLbl.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        
        contrastSwitch = UISwitch()
        view.addSubview(contrastSwitch)
        contrastSwitch.isOn = true
        contrastSwitch.addTarget(self, action: #selector(switchImage), for: .valueChanged)
        contrastSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contrastSwitch.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor),
            contrastSwitch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
        ])
        
        let markLbl = UILabel()
        view.addSubview(markLbl)
        markLbl.text = "AI标识"
        markLbl.textColor = .white
        markLbl.font = .systemFont(ofSize: 13)
        markLbl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            markLbl.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor),
            markLbl.rightAnchor.constraint(equalTo: contrastSwitch.leftAnchor, constant: -5),
        ])
        
        if fromPhotoPage{
            discardBtn = UIButton()
            view.addSubview(discardBtn!)
            discardBtn?.setTitle("取消保存", for: UIControl.State())
            discardBtn?.setTitleColor(#colorLiteral(red: 0.1294117647, green: 0.6549019608, blue: 0.8, alpha: 1), for: UIControl.State())
            discardBtn?.backgroundColor = .white
            discardBtn?.titleLabel?.font = .systemFont(ofSize: 15)
            discardBtn?.layer.cornerRadius = 18
            discardBtn?.addTarget(self, action: #selector(discardImage), for: .touchUpInside)
            discardBtn?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                discardBtn!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50 - heightOfAddtionalFooter),
                discardBtn!.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: view.frame.width * 0.3),
                discardBtn!.widthAnchor.constraint(equalToConstant: 100),
                discardBtn!.heightAnchor.constraint(equalToConstant: 36)
            ])
            
            againBtn = UIButton()
            view.addSubview(againBtn!)
            againBtn?.setTitle("再拍一张", for: UIControl.State())
            againBtn?.setTitleColor(.white, for: UIControl.State())
            againBtn?.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            againBtn?.titleLabel?.font = .systemFont(ofSize: 15)
            againBtn?.layer.cornerRadius = 18
            againBtn?.addTarget(self, action: #selector(photoAgain), for: .touchUpInside)
            againBtn?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                againBtn!.centerYAnchor.constraint(equalTo: discardBtn!.centerYAnchor),
                againBtn!.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: view.frame.width * 0.7),
                againBtn!.widthAnchor.constraint(equalTo: discardBtn!.widthAnchor),
                againBtn!.heightAnchor.constraint(equalTo: discardBtn!.heightAnchor)
            ])
        }

    }
    
    @objc private func backToHomepage(){
        if fromPhotoPage{
            DispatchQueue.global(qos: .userInteractive).async {[unowned self] in
                self.savePhoto()
            }
            navigationController?.popToRootViewController(animated: true)
        } else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func switchImage(){
        showOrigin.toggle()
        zoomView.image = showOrigin ? oriImage : capturesImage
    }
    
    @objc private func discardImage(){
        guard fromPhotoPage else {
            print("不是来自照相页面")
            return
        }
        let alert = UIAlertController(title: "确认丢弃当前图片？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认", style: .default){[unowned self]_ in
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.navigationBar.isHidden = false
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel){
            _ in return
        })
        self.present(alert,animated: true, completion: nil)
    }
    
    @objc private func photoAgain(){
        DispatchQueue.global(qos: .userInitiated).async {[unowned self] in
            self.savePhoto()
        }
        navigationController?.popViewController(animated: true)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - 保存图片和信息
    @objc private func savePhoto(){
        guard fromPhotoPage else {
            print("不是来自照相页面")
            return
        }
        sem.wait()
        let date = Date()
        /// 时间戳，对应照片编号（名称）
        let timeInterval = Int(date.timeIntervalSince1970)
        let timeFormatter = DateFormatter()
        //日期显示格式，可按自己需求显示
        timeFormatter.dateFormat = "yyyy_MM_dd"
        let folderName = timeFormatter.string(from: date) as String
        
        /// 文档路径：.../Documents/2020_10_22
        let albumDir:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(folderName)")
        // 往后推移
        if !FileManager.default.fileExists(atPath: albumDir.absoluteString){
            try? FileManager.default.createDirectory(at: albumDir, withIntermediateDirectories: true, attributes: nil)
        }
        //保存图片
        if let originData = oriImage?.jpegData(compressionQuality: 1.0), let capturesData = capturesImage?.jpegData(compressionQuality: 1.0) {
            do {
                let originDir = albumDir.appendingPathComponent("\(timeInterval).jpg")
                try originData.write(to: originDir)
                NSLog("%@ 保存成功", originDir.absoluteString)
                let captureDir = albumDir.appendingPathComponent("\(timeInterval)_tag.jpg")
                try capturesData.write(to: captureDir)
                NSLog("%@ 保存成功", captureDir.absoluteString)
                let infoDir = albumDir.appendingPathComponent("\(timeInterval).plist")
                try info.write(to: infoDir)
                NSLog("%@ 保存成功", infoDir.absoluteString)
                sem.signal()
            } catch {
                print("save picture error: ", error)
            }
        }

    }
    
    //MARK:保存图片到本地相册
    @objc private func albumSave(){
        let alert:UIAlertController
        if UIDevice.current.userInterfaceIdiom == .pad{
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        }
        else{
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        }
        alert.addAction(UIAlertAction(title: "保存原始图片到相册", style: .default, handler: {[unowned self] _ in
            UIImageWriteToSavedPhotosAlbum(self.oriImage!, self, #selector(self.saveImage), nil)
        }))
        alert.addAction(UIAlertAction(title: "保存标识图片到相册", style: .default, handler:{[unowned self] _ in
            UIImageWriteToSavedPhotosAlbum(self.capturesImage!, self, #selector(self.saveImage), nil)
        } ))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if error != nil{
            print("\(image.description)保存到相册失败")
            let feedback = UIAlertController(title: nil, message: "图片保存失败", preferredStyle: .alert)
            self.present(feedback, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    feedback.dismiss(animated: true, completion: nil)
                }
            }
        }else{
            print("\(image.description)保存到相册成功")
            let feedback = UIAlertController(title: nil, message: "图片保存成功", preferredStyle: .alert)
            self.present(feedback, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    feedback.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
