//
//  AlertHelper.swift
//  xGallary
//
//  Created by Arslan on 11/07/2018.
//  Copyright © 2018 Arslan. All rights reserved.
//

import UIKit

class AlertHelper: NSObject {
    
    public static func showOKAllert(title: String, message: String, style: UIAlertActionStyle, VC: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: style, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        VC.present(alert, animated: true, completion: nil)
    }

}
