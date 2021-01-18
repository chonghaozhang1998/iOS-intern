//
//  CTImages.swift
//  CTDemo
//
//  Created by RodinYTY on 2020/10/24.
//

import Foundation

struct CTImage{
    /// 时间戳，即文件标识符
    var timeInterval: String
    var origin: URL
    var tag: URL
    var infoDict: NSMutableDictionary
}

struct CTImageGroup {
    var year: Int16
    var month: Int8
    var day: Int8
    var folder: URL?
    var images: Array<CTImage>
    
    /// 返回日期的字符串形式
    func date() -> String{
        let date = Date(timeIntervalSince1970: TimeInterval(images[0].timeInterval)!)
        let components = NSCalendar.current.dateComponents(Set<Calendar.Component>.init(arrayLiteral: .year, .month, .day), from: Date())
        //今天凌晨
        let todayStart = NSCalendar.current.date(from: components)!
        //明天凌晨
        let todayEnd = NSCalendar.current.date(byAdding: .hour, value: 24, to: todayStart)!

        //时间差=明天凌晨-分组日期
        switch Calendar.current.dateComponents([.day], from: date, to: todayEnd).day!{
        case 0:
            return "今天"
        case 1:
            return "昨天"
        default:
            return String(format: "%d月%d日", arguments: [month, day])
        }
    }
    
}

// CTImageGroup对象的比较
func >=(obj1: CTImageGroup, obj2: CTImageGroup) -> Bool {
    if obj1.year == obj2.year{
        if obj1.month == obj2.month{
            return obj1.day >= obj2.day
        } else{
            return obj1.month > obj2.month
        }
    } else{
        return obj1.year > obj2.year
    }
}
