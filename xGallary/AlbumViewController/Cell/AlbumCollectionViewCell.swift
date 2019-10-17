
//
//  AlbumCollectionViewCell.swift
//  xGallary
//
//  Created by Arslan on 05/07/2018.
//  Copyright © 2018 Arslan. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imgAlbumItem: UIImageView!
    
    @IBOutlet var blurView: UIView!
    
    @IBOutlet var btnLock: UIButton!

    @IBOutlet var selectionView: UIView!
    
    @IBOutlet var lockView: UIView!
    
    @IBOutlet var btnSelect: UIButton!
    
    public func setImage(img: UIImage) {
        self.imgAlbumItem.image = img
    }
    
    
}
