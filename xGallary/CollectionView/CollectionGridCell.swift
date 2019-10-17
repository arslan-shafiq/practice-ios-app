//
//  CollectionGridCell.swift
//  xGallary
//
//  Created by Arslan on 04/07/2018.
//  Copyright © 2018 Arslan. All rights reserved.
//

import UIKit

class CollectionGridCell: UICollectionViewCell {
    
    @IBOutlet var lblAlbumTitle: UILabel!
    
    @IBOutlet var blueView: UIView!
    
    
    @IBOutlet var imgAlbumThumb: UIImageView!
    @IBOutlet var btnLock: UIButton!
    
    public func setAlbumTitle(title: String) {
        self.lblAlbumTitle.text = title
    }
    
    public func setAlbumThumb(thumb: UIImage) {
        self.imgAlbumThumb.image = thumb
    }
    
    
    
}
