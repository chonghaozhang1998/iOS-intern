//
//  MLModel.swift
//  CTDemo
//
//  Created by RodinYTY on 2020/10/19.
//

import CoreML

class CTMLModel {
    /// 椭圆占比
    var ratio: Double = 0
    private var oriImage: UIImage?
    private var combineImage: UIImage?
    
    // MARK: - 覆写init
    init(originImage: UIImage?, combineImage: UIImage?){
        self.oriImage = originImage
        self.combineImage = combineImage
    }

    func getResultImage() -> (UIImage?, NSMutableDictionary) {
        var timer1 = Timer(), timer2 = Timer(), timer3 = Timer(), timer4 = Timer()
        var _progress:CGFloat = 0.0
        NSLog("开始识别CT图")
        //模拟进度条：0~5
        DispatchQueue.main.async {
            _progress = 0 / 21
            timer1 = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true){_ in
                if _progress >= 5/21{
                    timer1.invalidate()
                }
                else{
                    NotificationCenter.default.post(name: .init("updateProgress"), object: self, userInfo: ["progress": _progress as CGFloat])
                    _progress += 1 / 21
                }
            }
        }
        //模型输入处理
        /// [512, 512] Array
        let imageArr = OpenCVMethod.getGrayImageData(combineImage!) as! [Float]
        var inputArr = [Float]()

        for _ in 0...2 {
            inputArr.append(contentsOf: imageArr)
        }
        /// [1, 3, 512, 512] Array
        //模拟进度条：5~12
        DispatchQueue.main.async {
            _progress = 5 / 21
            timer2 = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true){_ in
                if _progress >= 12/21{
                    timer2.invalidate()
                }
                else{
                    NotificationCenter.default.post(name: .init("updateProgress"), object: self, userInfo: ["progress": _progress as CGFloat])
                    _progress += 1 / 21
                }
            }
        }
        
        //模拟进度条：12~17
        DispatchQueue.main.async {
            _progress = 12 / 21
            timer3 = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true){_ in
                if _progress >= 17/21{
                    timer3.invalidate()
                }
                else{
                    NotificationCenter.default.post(name: .init("updateProgress"), object: self, userInfo: ["progress": _progress as CGFloat])
                    _progress += 1 / 21
                }
            }
        }
        //结果处理(这里没有使用模型输出结果，使用指定大小的数组)
        let output:[Float] = [Float](repeating: 0, count: 512*512)
        let out: [Int] = output.map { (item) -> Int in
            let aroundItem = lroundf(item * 255.0)
            if aroundItem >= 128 {
                return 255
            } else {
                return 0
            }
        }
        
        /// 病灶点个数
        let count:Int = out.reduce(0, {(x, y) in x + y}) / 255
        let areaRatio:Double = Double(count) / 512.0 / 512.0 / ratio
        let infoDict = NSMutableDictionary()
        infoDict.setValue(count, forKey: "count")
        infoDict.setValue(areaRatio, forKey: "ratio")
        print("病灶像素点数：\(count), 病灶占比\(areaRatio)")
        //模拟进度条：17~21
        DispatchQueue.main.async {
            _progress = 17 / 21
            timer4 = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true){_ in
                if _progress >= 21/21{
                    NotificationCenter.default.post(name: .init("updateProgress"), object: self, userInfo: ["progress": 1.0 as CGFloat])
                    timer4.invalidate()
                }
                else{
                    NotificationCenter.default.post(name: .init("updateProgress"), object: self, userInfo: ["progress": _progress as CGFloat])
                    _progress += 1 / 21
                }
            }
        }
        let newImage = OpenCVMethod.convertArray(toImage: NSMutableArray(array: out))
        //图片拼接
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: combineImage!.size, format: format)
        let combineImage = renderer.image { [unowned self](context) in
            oriImage?.draw(in: CGRect(x: 0, y: 0, width: self.combineImage!.size.width, height: self.combineImage!.size.height))
            newImage.draw(in: CGRect(x: 0, y: 0, width: self.combineImage!.size.width, height: self.combineImage!.size.height))
        }
        NSLog("结束识别CT图")
        return (combineImage, infoDict)
    }
    

}

