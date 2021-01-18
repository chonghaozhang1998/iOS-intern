import UIKit

/// 带有刻度的自定义滑块
class MarkSlider: UISlider {
    //刻度位置集合
    var markPositions:[CGFloat] = []
    //病灶位置集合
    var focusPositions:[CGFloat] = []
    //刻度颜色
    var markColor: UIColor!
    //左侧轨道的颜色
    var leftBarColor: UIColor!
    //右侧轨道的颜色
    var rightBarColor:UIColor!
    //轨道高度
    var barHeight: CGFloat!
    //开始和结束位置
    var startPos: Double!
    var endPos: Double!
    
    //初始化
    init(frame: CGRect, startPos start: Double, endPos end: Double) {
        super.init(frame: frame)
        
        self.startPos = start
        self.endPos = end
        //设置样式的默认值
        self.markPositions = [10,20,30,40,50,60,70,80,90].map({
            $0 / 100
        })
        self.markColor = UIColor(red: 255, green: 165, blue: 0)

        self.leftBarColor = UIColor(red: 55/255.0, green: 55/255.0, blue: 94/255.0,
                                    alpha: 0.8)
        self.rightBarColor = UIColor(red: 179/255.0, green: 179/255.0, blue: 193/255.0,
                                     alpha: 0.8)
        self.barHeight = 12
    }
    
    
    /// 定义刻度slider
    /// - Parameters:
    ///   - frame: 框架
    ///   - steps: 有几个刻度
    ///   - leftBarColor: 左轨道颜色
    ///   - rightBarColor: 右轨道颜色
    ///   - barHeight: 轨道高度
    convenience init(frame: CGRect, steps: Int, leftBarColor: UIColor, rightBarColor: UIColor, barHeight: CGFloat){
        self.init(frame: frame, startPos: 10, endPos: 90)

        self.markPositions = Array<CGFloat>()
        //自动生成均匀刻度
        for i in stride(from: startPos, through: endPos, by: (endPos - startPos) / Double(steps - 1)){
            self.markPositions.append(CGFloat(i) / 100)
        }
        self.focusPositions = self.markPositions
        print("Slider步长/病灶位置数组：\(self.markPositions)")
        self.leftBarColor = leftBarColor
        self.rightBarColor = rightBarColor
        self.barHeight = barHeight
        if steps == 1{
            self.isEnabled = false
        }
    }
    
    /// 不均匀刻度的slider初始化
    /// - Parameters:
    ///   - depthArr: 病灶的深度数组，e.g. [-100, -110, -130]
    ///   - focusIndexMark: 包含病灶的索引，e.g. {0, 2}
    convenience init(frame: CGRect, startPos start: Double, endPos end: Double,
                     depthArr: ArraySlice<Int>, focusIndexMark: Set<Int>, leftBarColor: UIColor, rightBarColor: UIColor, barHeight: CGFloat){
        self.init(frame: frame, startPos: start, endPos: end)

        let firstElem = depthArr.first!, lastElem = depthArr.last!
        //生成不均匀刻度
        if depthArr.count == 1{
            self.markPositions = []
        }
        else{
            self.markPositions = depthArr.map { elem -> CGFloat in
                let first:Double = (-Double(elem) + Double(firstElem))
                let step:Double = endPos - startPos
                return CGFloat((first * step / Double(firstElem - lastElem) + startPos) / 100.0 as Double)
            }
        }
        for (i, pos) in self.markPositions.enumerated(){
            if focusIndexMark.contains(i){
                self.focusPositions.append(pos)
            }
        }
        print("病灶位置数组：\(self.focusPositions)")

        self.leftBarColor = leftBarColor
        self.rightBarColor = rightBarColor
        self.barHeight = barHeight
        self.value = self.markPositions.isEmpty ? 0 : Float(self.markPositions[0])
        if depthArr.count == 1 {
            self.isEnabled = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        //得到左侧带有刻度的轨道图片（注意：图片不拉伸）
        let leftTrackImage = createTrackImage(rect: rect, barColor: leftBarColor)
        
        //得到右侧带有刻度的轨道图片
        let rightTrackImage = createTrackImage(rect: rect, barColor: rightBarColor)
        
        //将前面生产的左侧、右侧轨道图片设置到UISlider上
        setMinimumTrackImage(leftTrackImage, for: .normal)
        setMaximumTrackImage(rightTrackImage, for: .normal)
    }
    
    //生成轨道图片
    private func createTrackImage(rect: CGRect, barColor:UIColor) -> UIImage {
        //开始图片处理上下文
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        //绘制轨道背景
        context.setLineCap(.round)
        context.setLineWidth(barHeight)
        context.move(to: CGPoint(x: barHeight / 2, y:rect.height / 2))
        context.addLine(to: CGPoint(x: rect.width - barHeight / 2, y: rect.height / 2))
        context.setStrokeColor(barColor.cgColor)
        context.strokePath()
        
        //绘制轨道上的刻度
        for i in 0..<focusPositions.count {
            context.setLineCap(.square)
            context.setLineWidth(barHeight)
            let position: CGFloat = focusPositions[i] * rect.width
            context.move(to: CGPoint(x: position - 0.5, y: rect.height / 2))
            context.addLine(to: CGPoint(x: position + 0.5, y: rect.height / 2))
            context.setStrokeColor(markColor.cgColor)
            context.strokePath()
        }
        
        //得到带有刻度的轨道图片
        let trackImage = UIGraphicsGetImageFromCurrentImageContext()!
        //结束上下文
        UIGraphicsEndImageContext()
        return trackImage
    }

}
