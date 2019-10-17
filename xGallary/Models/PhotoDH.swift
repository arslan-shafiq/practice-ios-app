//
//  Photo.swift
//  xGallary
//
//  Created by Arslan on 11/07/2018.
//  Copyright © 2018 Arslan. All rights reserved.
//

import UIKit

class PhotoDH: NSObject {
    
    public var image: UIImage?
    public var fileName: String = ""
    public var isLocked: Bool = false
    public var albumName: String = ""
    public var isThumbnail: Bool = false
    
    public var isSelected: Bool = false
    
    init(fileName: String, image: UIImage) {
        self.fileName = fileName
        self.image = image
    }
    
    override init() {
        
    }

}
