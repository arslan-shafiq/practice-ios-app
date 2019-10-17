//
//  AlbumDH.swift
//  xGallary
//
//  Created by Arslan on 10/07/2018.
//  Copyright © 2018 Arslan. All rights reserved.
//

import Foundation
import UIKit
class AlbumDH : NSObject, NSCoding{
    
    public var albumName: String = ""
    public var isLocked: Bool = false
    public var thumnail = UIImage()
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(albumName, forKey: "albumName")
        aCoder.encode(isLocked, forKey: "isLocked")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.albumName = aDecoder.decodeObject(forKey: "albumName") as! String
        self.isLocked = aDecoder.decodeBool(forKey: "isLocked")
    }
    
    override init() {
        
    }
    
    
    
}
