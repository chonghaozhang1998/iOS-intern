//
//  MCUModel.swift
//  CTDemo
//
//  Created by llj on 2020/10/6.
//

import UIKit
import CoreML

class MCUModel {
    private var model: MCUNet = {
        let config = MLModelConfiguration()
        config.allowLowPrecisionAccumulationOnGPU = true
        config.computeUnits = .all
        return try! MCUNet(configuration: config)
    }()
    
    var oriImage: UIImage!
    var image: UIImage!
    
    init(image: UIImage, oriImage: UIImage) {
        self.image = image
        self.oriImage = oriImage
    }
    
    func getResultImage() -> UIImage? {
        
        //模型输入处理
        /// [512, 512] Array
        let imageArr = OpenCVMethod.getGrayImageData(image!) as! [Float]
        var inputArr = [Float]()
        for _ in 0...2 {
            inputArr.append(contentsOf: imageArr)
        }
        /// [1, 3, 512, 512] Array
        let inputTensor = toTensor(shape: [1, 3, 512, 512], array: inputArr)
        
        //模型预测
        guard let prediction = try? self.model.prediction(input: inputTensor) else { return nil }
        
        //结果处理
        let output = prediction.output.toFloatArray()[0..<(512 * 512)]
        let out: [Int] = output.map { (item) -> Int in
            let aroundItem = lroundf(item * 255.0)
            if aroundItem >= 128 {
                return 255
            } else {
                return 0
            }
        }
        let newImage = OpenCVMethod.convertArray(toImage: NSMutableArray(array: out))
        
        //图片拼接
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        let combineImage = renderer.image { (context) in
            oriImage.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            newImage.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }
        
        return combineImage
    }
    
    /// 生成MLMultiArray数组
    ///  - Parameter shape: 数组维度，如[19,1,267,9]
    ///  - Parameter array: 数组内容，一维形式，如[1, 2, 3, .... , ]
    ///  - Returns: MLMultiArray数组
    private func toTensor(shape: [Int], array: [Float]) -> MLMultiArray {
        let arr = try! MLMultiArray(shape: shape as [NSNumber], dataType: .float32)
        let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(arr.dataPointer))
        
        for i in 0..<arr.count {
            ptr.advanced(by: i).pointee = Float32(array[i])
        }
        return arr
    }
}

extension MLMultiArray {
    /// 可视化MLMultiArray,将MLMultiArray转换成Array数组
    /// - Returns: Array数组
    func toFloatArray() -> [Float32] {
        var arr: [Float32] = Array(repeating: 0, count: self.count)
        let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(self.dataPointer))
        for i in 0..<self.count {
            arr[i] = Float32(ptr[i])
        }
        return arr
    }
}
