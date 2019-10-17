//
//  BlurPasswordLoginViewController.swift
//
//  Created by rain on 4/22/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import UIKit
import SmileLock

//MARK: Delegate for response
protocol PasswordResponseDelegate: class {
    //    func changeBackgroundColor(_ color: UIColor?)
    func onResult(result: Bool)
    func blurPasswordIsBeingDismissed()
}

class BlurPasswordLoginViewController: UIViewController {
    
    @IBOutlet weak var passwordStackView: UIStackView!
    
    var strTitle: String = ""
    
    @IBOutlet var lblTitle: UILabel!
    
    weak var delegate: PasswordResponseDelegate?
    var falseCount: Int = 0;
    
    //MARK: Property
    var passwordUIValidation: MyPasswordUIValidation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create PasswordUIValidation subclass
        passwordUIValidation = MyPasswordUIValidation(in: passwordStackView)
        
        lblTitle.text = self.strTitle
        
        passwordUIValidation.success = { [weak self] _ in
            print("*️⃣ success!")
            self?.falseCount = 0
//            self?.delegate?.onResult(result: true)
//            self?.dismiss(animated: true, completion: nil)
            
            self?.dismiss(animated: true, completion: {
                
                self?.delegate?.onResult(result: true)
                
            })
            
        }
        
        passwordUIValidation.failure = {
            //do not forget add [weak self] if the view controller become nil at some point during its lifetime
            self.falseCount = self.falseCount + 1
            
            print("*️⃣ failure!")
            if (self.falseCount > 2) {
                self.falseCount = 0
                self.dismiss(animated: true, completion: {
                    
                    kstrTempPassword = ""
                    self.delegate?.blurPasswordIsBeingDismissed()
                    self.delegate?.onResult(result: false)
                    
                })
//
            } else {
                self.delegate?.onResult(result: false)
                
            }
            
            
            
        }
        
        //visual effect password UI
        passwordUIValidation.view.rearrangeForVisualEffectView(in: self)
        
        passwordUIValidation.view.deleteButtonLocalizedTitle = "Delete"
        
        // customize font
        //        for inputView in passwordUIValidation.view.passwordInputViews {
        //             inputView.labelFont = UIFont(name: "Chalkduster", size: 29)
        //        }
    }
}
