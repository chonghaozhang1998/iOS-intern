//
//  drawADottedLine.swift
//  demo_1
//
//  Created by RodinYTY on 2020/8/8.
//  Copyright © 2020 RodinYTY. All rights reserved.
//

import UIKit

/// 返回一条虚线
/// - Parameters:
///   - width: view和线长度
///   - height: view高度
///   - lineWidth: 线粗细
///   - color: 线颜色
///   - filledWidth: 实线部分宽度
///   - clearedWidth: 空白部分宽度
/// - Returns: 返回UIView
func drawADottedLine(viewWidth width:Int, viewHeight height:Int, lineWidth:CGFloat, lineColor color: UIColor, filledWidth:Int, clearedWidth:Int) ->UIView{
    let lineView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
    let shapeLayer:CAShapeLayer = CAShapeLayer()
    shapeLayer.bounds = lineView.bounds
    //线在view中的位置
    shapeLayer.position = CGPoint(x: 0, y: lineView.frame.height / 2)
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.lineWidth = lineWidth
    shapeLayer.lineJoin = CAShapeLayerLineJoin.round
    shapeLayer.lineDashPhase = 0
    shapeLayer.lineDashPattern = [NSNumber(value: filledWidth), NSNumber(value: clearedWidth)]
    let path:CGMutablePath = CGMutablePath()
    path.move(to: CGPoint(x: 0, y: 10))
    path.addLine(to: CGPoint(x: lineView.frame.width, y: 10))
    shapeLayer.path = path
    lineView.layer.addSublayer(shapeLayer)
    return lineView
}

func drawDashLineFor(view:UIView, strokeColor: UIColor, lineWidth: CGFloat = 1, lineLength: Int = 10, lineSpacing: Int = 5, corners: UIRectEdge) {
    let shapeLayer = CAShapeLayer()
    shapeLayer.bounds = view.bounds
    shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
    shapeLayer.fillColor = UIColor.blue.cgColor
    shapeLayer.strokeColor = strokeColor.cgColor
    shapeLayer.lineWidth = lineWidth
    shapeLayer.lineJoin = CAShapeLayerLineJoin.round
    //每一段虚线长度 和 每两段虚线之间的间隔
    shapeLayer.lineDashPattern = [NSNumber(value: lineLength), NSNumber(value: lineSpacing)]
    let path = CGMutablePath()
    if corners.contains(.left) {
        path.move(to: CGPoint(x: 0, y: view.layer.bounds.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
    }
    if corners.contains(.top){
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: view.layer.bounds.width, y: 0))
    }
    if corners.contains(.right){
        path.move(to: CGPoint(x: view.layer.bounds.width, y: 0))
        path.addLine(to: CGPoint(x: view.layer.bounds.width, y: view.layer.bounds.height))
    }
    if corners.contains(.bottom){
        path.move(to: CGPoint(x: view.layer.bounds.width, y: view.layer.bounds.height))
        path.addLine(to: CGPoint(x: 0, y: view.layer.bounds.height))
    }
    shapeLayer.path = path
    view.layer.addSublayer(shapeLayer)
}
