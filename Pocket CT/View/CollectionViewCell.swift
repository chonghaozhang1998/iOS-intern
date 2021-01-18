//
//  CollectionViewCell.swift
//  Homepage
//
//  Created by chasingzch on 2020/10/27.
//

import UIKit

open class CollectionViewCell: UICollectionViewCell {
    static let ID = "CollectionViewCell"
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        addSubview(imageView)
        
    }
    
    func configCell(with image: UIImage?) {
        if let image = image {
            imageView.image = image
        }
    }
}
