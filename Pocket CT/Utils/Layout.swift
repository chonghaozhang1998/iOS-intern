//
//  layout.swift
//  demo_1
//
//  Created by RodinYTY on 2020/8/6.
//  Copyright © 2020 RodinYTY. All rights reserved.
//

import UIKit

/// 计算属性：屏幕宽度
var screen_width:CGFloat {
    return UIScreen.main.bounds.width
}

/// 计算属性：屏幕高度
var screen_height:CGFloat {
    return UIScreen.main.bounds.height
}
/// 刘海高度
let heightOfAddtionalHeader:CGFloat = {
    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    return (window?.safeAreaInsets.top)!
}()

/// 状态栏高度
let statusBarHeight:CGFloat = {
    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0 // 20, 48
}()

///底部安全距离
let heightOfAddtionalFooter:CGFloat = {
    if UIDevice.current.isiPhoneXorLater(){
        return 34.0
    }
    else{
        return 0.0
    }
}()

extension UIDevice{
    /// 判断设备是不是iPhoneX以及以上
    /// - Returns: 返回Bool
    
    func isiPhoneXorLater() ->Bool{
        let screenHieght = UIScreen.main.nativeBounds.size.height
        //还没适配12pm
        if screenHieght == 2436 || screenHieght == 1792 || screenHieght == 2688 || screenHieght == 1624 || screenHieght == 2532{
            return true
        }
        else{
            return false
        }
    }
}

///水平居中
func horizontally(_ viewWidth:Int) ->Int{
    return Int((Int(UIScreen.main.bounds.width)/2) - (viewWidth/2))
}

/// 垂直居中
func vertically(_ viewHeight:Int) ->Int{
    return Int((Int(UIScreen.main.bounds.height)/2) - (viewHeight/2))
}

/// 根据文字获取宽度
func ga_widthForComment(str: String,fontSize: CGFloat, height: CGFloat = 15) -> CGFloat {
    let font = UIFont.systemFont(ofSize: fontSize)
    let rect = NSString(string: str).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    return ceil(rect.width)
}

/// 根据文字获取高度
func ga_heightForComment(str: String,fontSize: CGFloat, width: CGFloat) -> CGFloat {
    let font = UIFont.systemFont(ofSize: fontSize)
    let rect = NSString(string: str).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    return ceil(rect.height)
}

/// 根据文字获取高度
func ga_heightForComment(str: String,fontSize: CGFloat, width: CGFloat, maxHeight: CGFloat) -> CGFloat {
    let font = UIFont.systemFont(ofSize: fontSize)
    let rect = NSString(string: str).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    return ceil(rect.height)>maxHeight ? maxHeight : ceil(rect.height)
}

/// 获取Tab的高
func getTabBarHeight() -> (CGFloat){
    let tabBarController = UITabBarController()
    let height = tabBarController.tabBar.bounds.height
    //        let dv: UIDevice = UIDevice.current
    //        print("设备信息：\(dv.localizedModel)")
    if (UIScreen.main.bounds.height >= 812){
        return 83
    } else {
        return height
    }
}

extension UIButton{
    //MARK: -定义button相对label的位置
    enum RGButtonImagePosition {
        case top          //图片在上，文字在下，垂直居中对齐
        case bottom       //图片在下，文字在上，垂直居中对齐
        case left         //图片在左，文字在右，水平居中对齐
        case right        //图片在右，文字在左，水平居中对齐
    }
    /// - Description 设置Button图片的位置
    /// - Parameters:
    ///   - style: 图片位置
    ///   - spacing: 按钮图片与文字之间的间隔
    func imagePosition(style: RGButtonImagePosition, spacing: CGFloat) {
        //得到imageView和titleLabel的宽高
        let imageWidth = self.imageView?.frame.size.width
        let imageHeight = self.imageView?.frame.size.height
        
        var labelWidth: CGFloat! = 0.0
        var labelHeight: CGFloat! = 0.0
        
        labelWidth = self.titleLabel?.intrinsicContentSize.width
        labelHeight = self.titleLabel?.intrinsicContentSize.height
        
        //初始化imageEdgeInsets和labelEdgeInsets
        var imageEdgeInsets = UIEdgeInsets.zero
        var labelEdgeInsets = UIEdgeInsets.zero
        
        //根据style和space得到imageEdgeInsets和labelEdgeInsets的值
        switch style {
        case .top:
            //上 左 下 右
            imageEdgeInsets = UIEdgeInsets(top: -labelHeight-spacing/2, left: 0, bottom: 0, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth!, bottom: -imageHeight!-spacing/2, right: 0)
            break;
            
        case .left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: -spacing/2)
            break;
            
        case .bottom:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight!-spacing/2, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets(top: -imageHeight!-spacing/2, left: -imageWidth!, bottom: 0, right: 0)
            break;
            
        case .right:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth+spacing/2, bottom: 0, right: -labelWidth-spacing/2)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth!-spacing/2, bottom: 0, right: imageWidth!+spacing/2)
            break;
            
        }
        
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
        
    }
}

