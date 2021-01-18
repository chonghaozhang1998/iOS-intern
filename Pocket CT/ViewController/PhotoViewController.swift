//
//  ViewController.swift
//  CTDemo
//
//  Created by llj on 2020/10/6.
//

import UIKit
import AVFoundation

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
    var cameraManager: CameraManager!
    
    var cameraView: UIView!
    
    var maskLayer: CALayer!

    var rectLayer: CAShapeLayer!
    
    /// 外围矩形框
    var rectLineLayer: CAShapeLayer!
    /// 椭圆虚线框
    var ovalLayer: CAShapeLayer!
    
    var photoButton: UIButton!
    
    var ovalView: UIView!
    var ovalRect: CGRect = .zero
    //椭圆参数
    var rectWidth: CGFloat = 0
    var offsetY: CGFloat = 0
    var offsetX: CGFloat = 0
    //闪光灯
    private var lightBtn: UIButton?
    //进度条
    private var progressPanel: UIProgressPanel!
    
    private var libBtn: UIButton!
    private var tintBtn: UIButton!
    private var imagePicker = UIImagePickerController()
    
    // MARK: - 覆写init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    init(){
        super.init(nibName:nil, bundle:nil)
        cameraManager = CameraManager()
        
        cameraView = UIView()
        
        rectLayer = CAShapeLayer()
        rectLayer.fillColor = UIColor.white.cgColor
        rectLayer.strokeColor = UIColor.white.cgColor
        
        maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor(red: 0/255,
                                            green: 0/255,
                                            blue: 0/255,
                                            alpha: 0.5).cgColor
        maskLayer.addSublayer(rectLayer)
        
        /// 外围矩形框
        rectLineLayer = CAShapeLayer()
        
        /// 椭圆虚线框
        ovalLayer = CAShapeLayer()
        
        photoButton = UIButton()
        
        progressPanel = UIProgressPanel()
        
        self.title = "拍摄CT片"
        
        self.view.backgroundColor = .black
        
        //识别更新进度条的观察者
        NotificationCenter.default.addObserver(self, selector: #selector(setProgressPanel(notification:)), name: NSNotification.Name("updateProgress"), object: nil)
    }
    
//    var mcuModel: MCUModel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.cameraManager.updatePreviewFrame()
        self.setupUI()

        do {
            try cameraManager.captureSetup(in: cameraView, withPosition: .back)
        } catch {
            let alertController = UIAlertController(title: "Error",
                                                    message: error.localizedDescription,
                                                    preferredStyle: .alert)
            alertController.addAction(.init(title: "ok", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        photoButton.isEnabled = true
        navigationController?.navigationBar.isHidden = true
        //放到串行队列异步执行，防止阻塞
        DispatchQueue.main.async{
            self.cameraManager.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?
            .interactivePopGestureRecognizer?
            .isEnabled = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        cameraManager.transitionCamera()
    }
    
    
    // MARK: - 触控移动监听坐标
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let touch:UITouch = touch as! UITouch
            let frame = tintBtn.frame
            //扩展button的触控范围
            let tintRangePlus = CGRect(x: frame.minX - 40, y: frame.minY - 30, width: frame.width + 80, height: frame.height + 60)
            let maxRange = CGRect(x: frame.minX - 40, y: rectLayer.frame.minY + offsetX, width: frame.width + 80, height: (rectLayer.frame.height / 2 - offsetX) * 0.6)
            if tintRangePlus.contains(touch.location(in: view)) && maxRange.contains(touch.location(in: view)){
//                NSLog("point: \(touch.location(in: self.view))")
                tintBtn.isHighlighted = true
                //分离y坐标
                let y = touch.location(in: self.view).y
                UIView.animate(withDuration: 0.01, animations: {[unowned self] in
                    self.tintBtn.center.y = y
                })
                
                offsetY = y - rectLayer.frame.minY
                //重画内部椭圆
                let cameraSize = self.cameraView.frame.size
                let originY = ((cameraSize.height - rectWidth)/2) * 0.9
                let originX = (cameraSize.width - rectWidth)/2
                ovalView.frame = CGRect(x: originX + offsetX, y: originY + offsetY, width: rectWidth - 2 * offsetX, height: rectWidth - 2 * offsetY)
                let ovalPath = UIBezierPath(ovalIn: ovalView.bounds)
                ovalLayer.path = ovalPath.cgPath
                ovalLayer.strokeColor = UIColor.orange.cgColor
                ovalLayer.lineDashPattern = [10, 5]
                ovalLayer.lineWidth = 2
                ovalLayer.fillColor = nil
                ovalView.layer.mask = ovalLayer
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        tintBtn.isHighlighted = false
    }
    
    private func setupUI() {
        view.addSubview(cameraView)
        cameraView.frame = self.view.bounds
        cameraView.layer.mask = maskLayer
        
        view.addSubview(photoButton)
        photoButton.setImage(UIImage(named: "photo"), for: UIControl.State.normal)
        photoButton.addTarget(self, action: #selector(photo(_:)), for: .touchUpInside)
        photoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10 - heightOfAddtionalFooter),
            photoButton.widthAnchor.constraint(equalToConstant: 75),
            photoButton.heightAnchor.constraint(equalToConstant: 75)
        ])
        
//        lightBtn = UIButton()
//        self.view.addSubview(lightBtn!)
//        lightBtn?.setTitle("闪光灯", for: .normal)
//        lightBtn?.setTitleColor(.white, for: .normal)
//        lightBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        lightBtn?.addTarget(self, action: #selector(light), for: .touchUpInside)
//        lightBtn?.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            lightBtn!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
//            lightBtn!.topAnchor.constraint(equalTo: view.topAnchor, constant: heightOfAddtionalHeader + 100),
//            lightBtn!.widthAnchor.constraint(equalToConstant: 50),
//            lightBtn!.heightAnchor.constraint(equalToConstant: 20)
//        ])
        
        libBtn = UIButton()
        view.addSubview(libBtn)
        libBtn.setImage(UIImage(named: "library"), for: UIControl.State())
        libBtn.addTarget(self, action: #selector(openLibrary), for: .touchUpInside)
        libBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            libBtn.centerYAnchor.constraint(equalTo: photoButton.centerYAnchor),
            libBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.frame.width * 0.13),
            libBtn.widthAnchor.constraint(equalToConstant: 43),
            libBtn.heightAnchor.constraint(equalToConstant: 43)
        ])
        
        let backView = UIView()
        backView.backgroundColor = #colorLiteral(red: 0.1254901961, green: 0.5921568627, blue: 0.7529411765, alpha: 1)
        view.insertSubview(backView, at: 1)
        backView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backView.topAnchor.constraint(equalTo: photoButton.topAnchor, constant: -15),
            backView.widthAnchor.constraint(equalTo: view.widthAnchor),
            backView.heightAnchor.constraint(equalToConstant: heightOfAddtionalFooter + 75 + 10 + 15)
        ])
        
        self.drawOverRectView()
        imagePicker.delegate = self
        
        let tintWidth:CGFloat = 30.0, tintHeight:CGFloat = 25
        tintBtn = UIButton(frame: CGRect(x: screen_width / 2 - tintWidth / 2, y: rectLayer.frame.minY + offsetY - tintHeight / 2, width: tintWidth, height: tintHeight))
        tintBtn.setBackgroundImage(UIImage(named: "tint"), for: UIControl.State())
        view.insertSubview(tintBtn, at: 2)
        
        let tipBtn = UIButton()
        view.addSubview(tipBtn)
        tipBtn.setBackgroundImage(UIImage(named: "tip"), for: UIControl.State.normal)
        tipBtn.addTarget(self, action: #selector(showPhotoTip), for: .touchUpInside)
        tipBtn.translatesAutoresizingMaskIntoConstraints = false
        let tipBtnWidth = 100 as CGFloat
        NSLayoutConstraint.activate([
            tipBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: tipBtnWidth * 0.08),
            tipBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: heightOfAddtionalHeader + 30),
            tipBtn.widthAnchor.constraint(equalToConstant: tipBtnWidth),
            tipBtn.heightAnchor.constraint(equalToConstant: tipBtnWidth * 0.296),
        ])
        
        let backBtn = UIButton()
        view.addSubview(backBtn)
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backBtn.centerYAnchor.constraint(equalTo: tipBtn.centerYAnchor),
            backBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 28),
            backBtn.widthAnchor.constraint(equalToConstant: 22),
            backBtn.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    /// 开关闪光灯
    @objc private func light(){
        cameraManager.switchLight()
        if cameraManager.isLightOn{
            lightBtn?.setTitleColor(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), for: .normal)
        }
        else{
            lightBtn?.setTitleColor(.white, for: .normal)
        }
    }
    /// 拍摄区域框图绘制
    private func drawOverRectView() {
        let cameraSize = self.cameraView.frame.size
        let originY: CGFloat
        let originX: CGFloat

        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation

        switch orientation {
        case .landscapeRight, .landscapeLeft:
            rectWidth = (cameraSize.height)/1.4
        default:
            //if it is faceUp or portrait or any other orientation
            rectWidth = cameraSize.width/1.15
        }
        offsetX = 0.1 * rectWidth
        offsetY = 0.2 * rectWidth
        originY = ((cameraSize.height - rectWidth)/2) * 0.9
        originX = (cameraSize.width - rectWidth)/2

        //create a rect shape layer
        rectLayer.frame = CGRect(x: originX,
                                 y: originY,
                                  width: rectWidth,
                                 height: rectWidth)

        let bezierPathFrame = CGRect(origin: .zero,
                                     size: rectLayer.frame.size)
        //add beizier to rect shapelayer
        rectLayer.path = UIBezierPath(roundedRect: bezierPathFrame,
                                      cornerRadius: 10).cgPath

        //add shapelayer to layer
        maskLayer.frame = cameraView.bounds

        //白色外框
        let rectView = UIView(frame: rectLayer.frame)
        rectView.backgroundColor = .white
        view.addSubview(rectView)
        let linePath = UIBezierPath(roundedRect: rectLayer.bounds, cornerRadius: 10)
        rectLineLayer.path = linePath.cgPath
        rectLineLayer.strokeColor = UIColor.white.cgColor
        rectLineLayer.lineWidth = 4
        rectLineLayer.fillColor = nil
        rectView.layer.mask = rectLineLayer

        let tipLabel = UILabel()
        tipLabel.text = "手机拍摄CT影像片，每次拍摄一张"
        tipLabel.textColor = #colorLiteral(red: 0.7215686275, green: 0.8509803922, blue: 0.968627451, alpha: 1)
        tipLabel.font = .systemFont(ofSize: 14)
        tipLabel.textAlignment = .center
        view.addSubview(tipLabel)
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tipLabel.centerXAnchor.constraint(equalTo: rectView.centerXAnchor),
            tipLabel.bottomAnchor.constraint(equalTo: rectView.topAnchor, constant: -13),
            tipLabel.widthAnchor.constraint(equalToConstant: rectView.frame.width),
            tipLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        // MARK: 画椭圆
        ovalView = UIView(frame: CGRect(x: originX + offsetX, y: originY + offsetY, width: rectWidth - 2 * offsetX, height: rectWidth - 2 * offsetY))
        ovalView.backgroundColor = .red // #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        ovalView.alpha = 0.8
        view.addSubview(ovalView)
        ovalRect = ovalView.frame
//        print("rectLayer frame: ", rectLayer.frame)
//        print("ovalRect frame: ", ovalRect)
        let ovalPath = UIBezierPath(ovalIn: ovalView.bounds)
        ovalLayer.path = ovalPath.cgPath
        ovalLayer.strokeColor = UIColor.orange.cgColor
        ovalLayer.lineDashPattern = [10, 5]
        ovalLayer.lineWidth = 2
        ovalLayer.fillColor = nil
        ovalView.layer.mask = ovalLayer
        
    }
    
    private func cropOvalImage(with image: UIImage) -> UIImage {
        print("image Size: ", image.size)

        let scale = image.size.width / rectWidth
        let imageOffsetY = offsetY * scale
        let imageOffsetX = offsetX * scale
        let origin = CGPoint(x: imageOffsetX, y: imageOffsetY)
        let size = CGSize(width: image.size.width - 2 * imageOffsetX, height: image.size.height - 2 * imageOffsetY)
        // 设置renderer的格式
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 1
        rendererFormat.preferredRange = .standard
        let renderer = UIGraphicsImageRenderer(size: image.size, format: rendererFormat)
        //椭圆图片
        let cropImage = renderer.image { (context) in
            //设置裁剪区域
            let imageRect = CGRect(origin: origin, size: size)
            let clipPath = UIBezierPath(ovalIn: imageRect)
            clipPath.addClip()
            //绘制图片
            image.draw(at: .zero)
        }

        //增加背景
        let combineImage = renderer.image { (context) in
            context.fill(renderer.format.bounds)
            UIColor.black.setFill()
            cropImage.draw(at: .zero)
        }
        return combineImage
    }
    
    //MARK:点击拍照
    @objc private func photo(_ sender: UIButton) {
        //添加进度条
        progressPanel = UIProgressPanel(frame: CGRect(x: horizontally(Int(screen_width * 0.32)), y: vertically(Int(screen_width * 0.32)), width: Int(screen_width * 0.32), height: Int(screen_width * 0.32)))
        self.view.addSubview(progressPanel)
        cameraManager.cropRect = self.rectLayer.frame

        let settings = AVCapturePhotoSettings()
        let previewPixelType = AVCapturePhotoSettings().__availablePreviewPhotoPixelFormatTypes
        if previewPixelType.count > 0 {
            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType.first!]
        }
        cameraManager.photoOutput.capturePhoto(with: settings, delegate: self)
        photoButton.isEnabled = false
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        cameraManager.stopScreen()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        cameraManager.stopRunning()
    }
    
    //MARK:拍照取图回调
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        //图片裁剪
        guard let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage(data: imageData) else {
            return
        }
        cameraManager.stopRunning()
        var croppedImage:UIImage!
        do{
            croppedImage = try cameraManager.crop(image: capturedImage, withRect: cameraManager.cropRect ?? self.cameraView?.frame ?? .zero)
        }
        catch{ print("crop error") }
        let combineImage = cropOvalImage(with: croppedImage)

        //求识别信息
        let pi = 3.1415926535898 as Double
        let ratio:Double = (Double(self.rectWidth) / 2 - Double(self.offsetY)) * ((Double(self.rectWidth) / 2 - Double(self.offsetX)) * pi) / Double(self.rectWidth * self.rectWidth)
        print(self.rectWidth, self.offsetX, ratio)
        //运算
        DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
            let scanner = CTMLModel(originImage: croppedImage, combineImage: combineImage)
            scanner.ratio = ratio
            let ret = scanner.getResultImage()

            DispatchQueue.main.async { [unowned self] in
                UIView.animate(withDuration: 0.4, animations: {
                    self.progressPanel.alpha = 0

                }, completion: { (finished) in
                    // 直接传值给模型
                    let iVC = DisplayViewController(originImage: croppedImage, capturesImage: ret.0!, info: ret.1)
                    iVC.rect = self.rectLayer.frame
                    iVC.fromPhotoPage = true
                    self.navigationController?.pushViewController(iVC, animated: true)
                    self.progressPanel.removeFromSuperview()
                })
            }
        }
    }
    
    /// 更新progress的进度
    /// - Parameter notification: 传递的通知消息
    @objc private func setProgressPanel(notification: Notification){
        progressPanel.setProgress(progress: notification.userInfo?["progress"] as! CGFloat)
    }
    
    /// 打开相册
    @objc private func openLibrary(){
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)){
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Alert", message: "没有权限访问照片", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    // FIXME:拍照提示
    @objc private func showPhotoTip(){
        let tipVC = TipsViewController()
        present(tipVC, animated: true, completion: nil)
    }
    
    @objc private func back(){
        cameraManager.stopRunning()
        navigationController?.popViewController(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        cameraManager.startRunning()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    //MARK:相册取景结束
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            //添加进度条，需要先从view上移除
            progressPanel.removeFromSuperview()
            progressPanel = UIProgressPanel(frame: CGRect(x: horizontally(Int(screen_width * 0.32)), y: vertically(Int(screen_width * 0.32)), width: Int(screen_width * 0.32), height: Int(screen_width * 0.32)))
            self.imagePicker.view.addSubview(progressPanel)
            let combineImage = self.cropOvalImage(with: pickedImage)
            //运算
            DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
                //求识别信息
                let pi = 3.1415926535898 as Double
                let ratio:Double = (Double(self.rectWidth) / 2 - Double(self.offsetY)) * ((Double(self.rectWidth) / 2 - Double(self.offsetX)) * pi) / Double(self.rectWidth * self.rectWidth)
                let scanner = CTMLModel(originImage: pickedImage, combineImage: combineImage)
                scanner.ratio = ratio
                let ret = scanner.getResultImage()

                DispatchQueue.main.async { [unowned self] in
                    UIView.animate(withDuration: 0.4, animations: {
                        self.progressPanel.alpha = 0
                    }, completion: { (finished) in
                        // 直接传值给模型
                        let iVC = DisplayViewController(originImage: pickedImage, capturesImage: ret.0!, info: ret.1)
                        iVC.rect = self.rectLayer.frame
                        iVC.fromPhotoPage = true
                        self.navigationController?.pushViewController(iVC, animated: true)
                        self.imagePicker.dismiss(animated: true, completion: nil)
                        self.progressPanel.removeFromSuperview()
                    })
                }
            }
            photoButton.isEnabled = false
        }
    }
}
