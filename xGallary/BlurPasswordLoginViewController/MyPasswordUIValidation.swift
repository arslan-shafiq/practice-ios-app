//
//  MyPasswordUIValidation.swift
//  SmileLock-Example
//
//  Created by rain on 4/22/16.
//  Copyright © 2016 RECRUIT LIFESTYLE CO., LTD. All rights reserved.
//

import UIKit
import SmileLock

var kstrTempPassword = ""

class MyPasswordModel {
    class func match(_ password: String) -> MyPasswordModel? {
        if (kPassword == "") {
            if kstrTempPassword == "" {
                kstrTempPassword = password
            } else {
                guard password == kstrTempPassword else {
                    return nil
                }
                kPassword = password
                UserDefaults.standard.set(password, forKey: kStrPasswordKey)
                kstrTempPassword = ""
            }
            return MyPasswordModel()
        }
        guard password == kPassword else { return nil }
        return MyPasswordModel()
    }
}

class MyPasswordUIValidation: PasswordUIValidation<MyPasswordModel> {
    init(in stackView: UIStackView) {
        super.init(in: stackView, digit: kPasswordDigit)
        validation = { password in
            MyPasswordModel.match(password)
        }
    }
    
    //handle Touch ID
    override func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            let dummyModel = MyPasswordModel()
            self.success?(dummyModel)
        } else {
            passwordContainerView.clearInput()
        }
    }
}
