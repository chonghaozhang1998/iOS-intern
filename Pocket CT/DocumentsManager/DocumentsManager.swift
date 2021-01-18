//
//  DocumentsManager.swift
//  CTDemo
//
//  Created by RodinYTY on 2020/10/24.
//

open class DocumentsManager: NSObject {
    /// 单例
    static let `default`: DocumentsManager = DocumentsManager()
    
    /// 删除目标文件夹下所有的内容
    func removeFolder(folderUrlString:String){
        let fileManger = FileManager.default
        // 然后获得所有该目录下的子文件夹
        let files:[AnyObject]? = fileManger.subpaths(atPath: folderUrlString)! as [AnyObject]
        // 创建一个循环语句，用来遍历所有子目录
        for file in files!
        {
            do{
                //删除指定位置的内容
                try fileManger.removeItem(atPath: folderUrlString + "/\(file)")
                print("成功删除\(folderUrlString + "/\(file)")")
            }catch{ }
        }
    }
    
    /// 删除Documents下面所有目录
    func removeDirectories(){
        removeFolder(folderUrlString: NSHomeDirectory().appending("/Documents"))
    }
    
    /// 返回CT图册的所有分组，分组包含若干CT图册，图册包含3个URL和时间戳
    func getCTImageGroups() -> Array<CTImageGroup>{
        var groups = Array<CTImageGroup>()
        let manager = FileManager.default
        let docURL = URL(string: NSHomeDirectory() + "/Documents")!
        var namesOfFolders: [String] = []
        do{
            //符合yyyy_MM_dd的格式的文件夹
            namesOfFolders = try manager.contentsOfDirectory(atPath: docURL.absoluteString).filter{
                NSPredicate(format: "SELF MATCHES %@", "([0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})_(((0[13578]|1[02])_(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)_(0[1-9]|[12][0-9]|30))|(02-(0[1-9]|[1][0-9]|2[0-8])))").evaluate(with: $0)
            }
        }
        catch{ print("查找分组失败") }
        print("\n--------读取沙盒中图片缓存--------")
        print("分组总数：\(namesOfFolders.count)")
        for groupName in namesOfFolders{
            let date = groupName.split(separator: "_")
            let _year = Int16(String(date[0]))!, _month = Int8(String(date[1]))!, _day = Int8(String(date[2]))!
            let groupURL = docURL.appendingPathComponent(groupName)
            /// 该分组下文件名称
            let subpaths = manager.subpaths(atPath: docURL.appendingPathComponent(groupName).absoluteString)!
            var timeIntervals: Set<String> = getNonRepetitiveTimeIntervals(names: subpaths)
            if timeIntervals.contains(".DS"){
                timeIntervals.remove(".DS")
            }
            print(groupName + "：", timeIntervals)
            var _images = Array<CTImage>()
            for timeInterval in timeIntervals{
                let image = CTImage(timeInterval: timeInterval, origin: groupURL.appendingPathComponent("\(timeInterval).jpg"), tag: groupURL.appendingPathComponent("\(timeInterval)_tag.jpg"), infoDict: NSMutableDictionary(contentsOfFile: groupURL.appendingPathComponent("\(timeInterval).plist").absoluteString)!)
                _images.append(image)
            }
            var group = CTImageGroup(year: _year, month: _month, day: _day, images: _images.sorted(by: {
                $0.timeInterval < $1.timeInterval
            }))
            group.folder = _images.first?.origin.deletingLastPathComponent()
            groups.append(group)
        }
        print("---------图片缓存读取完毕---------\n")
        //返回逆序结果
        return groups.sorted(by: >=)
    }
    
    /// 给分组的时间戳去重
    /// - Parameter names: 名称数组
    /// - Returns: 相册集的唯一标识符的数组
    private func getNonRepetitiveTimeIntervals(names: [String]) -> Set<String>{
        var timeIntervals = Set<String>()
        for name in names{
            let lineIndex:String.Index? = name.firstIndex(of: "_")
            if let lineIndex = lineIndex{
                timeIntervals.insert(String(name[name.startIndex..<lineIndex]))
            }
            else{
                let dotIndex:String.Index? = name.firstIndex(of: ".")
                if let dotIndex = dotIndex{
                    timeIntervals.insert(String(name[name.startIndex..<dotIndex]))
                }
                else{
                    timeIntervals.insert(name)
                }
            }
        }
        return timeIntervals
    }
    
    /// 删除分组对应的文件夹
    func deleteDirectoryOfGroup(_ group: CTImageGroup) {
        guard let groupURL = group.folder else{
            print("删除文件夹失败：\(group.date())")
            return
        }
        let fileManger = FileManager.default
        do{
            //删除指定位置的内容
            try fileManger.removeItem(atPath: groupURL.absoluteString)
            print("成功删除\(groupURL.absoluteString)")
        }catch{ print("删除失败\(groupURL.absoluteString)") }
    }
    
    /// 删除图集对应的3个文件
    func deleteImagesOfCTImage(_ image: CTImage){
        let fileManger = FileManager.default
        print(image.origin.absoluteString)
        do{
            try fileManger.removeItem(atPath: image.origin.absoluteString)
            print("成功删除\(image.origin.absoluteString)")
            try fileManger.removeItem(atPath: image.tag.absoluteString)
            print("成功删除\(image.tag.absoluteString)")
            let dictURL = image.tag.deletingLastPathComponent().appendingPathComponent("\(image.timeInterval).plist")
            try fileManger.removeItem(atPath: dictURL.absoluteString)
            print("成功删除\(dictURL.absoluteString)")
        }catch{ print("删除失败：图集\(image.timeInterval)") }
    }
}
