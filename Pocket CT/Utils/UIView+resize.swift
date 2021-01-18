//
//  UIimage+resize.swift
//  UICollectionViewDemo
//
//  Created by llj on 2020/10/23.
//

import UIKit

extension UIImage {
    
    /// 调整图片大小以适应显示，减少原图渲染造成的内存激增
    /// - Parameters:
    ///   - image: 原始图片
    ///   - size: 将要调整的尺寸
    /// - Returns: 调整后的图片
    func resize(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    /// 按比例缩放
    /// - Parameter scaleSize: 缩放比
    /// - Returns: 调整后的图片
    func scaleImage(scaleSize: CGFloat)-> UIImage? {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return self.resize(to: reSize)
    }
}
