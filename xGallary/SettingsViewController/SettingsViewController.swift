//
//  SettingsViewController.swift
//  xGallary
//
//  Created by Arslan on 17/07/2018.
//  Copyright © 2018 Arslan. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, PasswordResponseDelegate{
    
    @IBOutlet var swtRequirePasswordOnLock: UISwitch!
    @IBOutlet var viewChangePassword: UIView!
    
    var updatingPassword: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        if (self.isPasswortSet()) {
        } else {
         showPasswordScreen(strTitle: "Set PIN")
        }
        
    }
    
    private func initUI() {
        let needPassword = UserDefaults.standard.bool(forKey: kStrUsePasswordToLock)
        self.swtRequirePasswordOnLock.isOn = needPassword
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.tapActionChangePassword(_:)))
        self.viewChangePassword.addGestureRecognizer(gesture)
    }
    
    
    @objc func tapActionChangePassword(_ sender:UITapGestureRecognizer){
        // do other task
        self.updatingPassword = true
        showPasswordScreen(strTitle: "Current PIN")
    }
    
    
    @IBAction func swtActionOnChange(_ sender: Any) {
        if (self.swtRequirePasswordOnLock.isOn) {
            UserDefaults.standard.set(true, forKey: kStrUsePasswordToLock)
        } else {
            UserDefaults.standard.set(false, forKey: kStrUsePasswordToLock)
        }
    }
    
    //MARK: Checking password set or not
    private func isPasswortSet() -> Bool {
        let password = UserDefaults.standard.string(forKey: kStrPasswordKey)
        return (password != nil)
    }
    
    
    private func showPasswordScreen(strTitle: String) {
        let loginVCID = "BlurPasswordLoginViewController"
        present(loginVCID, strTitle)
    }
    
    func present(_ id: String, _ strTitle: String) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: id) as! BlurPasswordLoginViewController
        loginVC.delegate = self
        loginVC.strTitle = strTitle
        
        loginVC.modalPresentationStyle = .overCurrentContext
        present(loginVC, animated: true, completion: nil)
    }
    
    func onResult(result: Bool) {
        if (!result) {
            return 
        }
        if (updatingPassword) {
            self.updatingPassword = false
            kPassword = ""
            kstrTempPassword = ""
            showPasswordScreen(strTitle: "Set PIN")
        } else if (kPassword == "" && kstrTempPassword != "") {
            showPasswordScreen(strTitle: "Confirm PIN")
        }
    
    }
    
    func blurPasswordIsBeingDismissed() {
        
        if (self.isPasswortSet()) {
            
        } else {
            showPasswordScreen(strTitle: "Set PIN")
        }
        
        
    }

    

}
