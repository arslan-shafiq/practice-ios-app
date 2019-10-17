//
//  XHeaderView.swift
//  xGallary
//
//  Created by Arslan on 04/07/2018.
//  Copyright © 2018 Arslan. All rights reserved.
//

import UIKit

//MARK: Delegate for header
protocol XHeaderViewDelegate: class {
    //    func changeBackgroundColor(_ color: UIColor?)
    func btnActionLockPressed()
}

class XHeaderView: UIView {

    
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnLock: UIButton!
    
    @IBOutlet var lblTitle: UILabel!
    weak var delegate: XHeaderViewDelegate?
    
    class func instanceFromNib() -> UIView {
        let nib =  UINib(nibName: "XHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        return nib
    }
    
    @IBAction func btnActionBack(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let navigationController = appDelegate.window?.rootViewController as! UINavigationController
        navigationController.popViewController(animated: true)
    }
    
    @IBAction func btnActionLock(_ sender: Any) {
        self.delegate?.btnActionLockPressed()
    }
    
    public func setTitle(title: String) {
        lblTitle.text = title
    }
    
    public func setRightButtonLabel(strLabel: String) {
        self.btnLock.setTitle(strLabel, for: .normal)
    }
    
}



