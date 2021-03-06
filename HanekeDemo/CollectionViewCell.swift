//
//  CollectionViewCell.swift
//  Haneke
//
//  Created by Hermes Pique on 9/17/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit
import Haneke

class CollectionViewCell: UICollectionViewCell {
    
    var imageView : PoqAsyncImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initHelper()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initHelper()
    }
    
    func initHelper() {
        imageView = PoqAsyncImageView(frame: self.contentView.bounds)
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        imageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.contentView.addSubview(imageView)
    }
    
    override func prepareForReuse() {
        imageView.prepareForReuse()
        imageView.image = nil
    }
    
}
