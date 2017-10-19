//
//  MyAccountViewController.swift
//  SimplyRead
//
//  Created by jim on 7/9/2017.
//
//

import UIKit

class MyAccountViewController: UIViewController, UITextFieldDelegate {

    var user: User!
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var fullnameText: UITextField!
//    @IBOutlet weak var postAddressText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var phoneText: UITextField!
    
    @IBOutlet weak var balanceText: UITextField!
    
    
    @IBOutlet weak var settleF2fSwitch: UISwitch!
    @IBOutlet weak var settleF2fDetailsText: UITextField!
    @IBOutlet weak var settleSfSwitch: UISwitch!
    @IBOutlet weak var settleSfAddressText: UITextField!
    
    var isEditingProfile: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // get user
//        let srTableBarController = self.tabBarController as! SRTabBarController
//        user = srTableBarController.user
        user = Me.sharedInstance.user
        
        // set attributes
        if user != nil {
            usernameText.text = user.username
            fullnameText.text = user.fullname
//            postAddressText.text = user.post_address
            emailText.text = user.email
            phoneText.text = user.phone
            balanceText.text = user.balance
            
            if user.settleF2fEnable == "true" {
                settleF2fSwitch.isOn = true
            } else {
                settleF2fSwitch.isOn = false
            }
            settleF2fDetailsText.text = user.settleF2fDetails
            if user.settleSfEnable == "true" {
                settleSfSwitch.isOn = true
            } else {
                settleSfSwitch.isOn = false
            }
            settleSfAddressText.text = user.settleSfAddress
        }
        
        var rightButton = UIBarButtonItem(title: "編輯", style: UIBarButtonItemStyle.plain, target: self, action: Selector(("showEditing:")))
        self.navigationItem.rightBarButtonItem = rightButton
        self.isEditingProfile = false;
        
        fullnameText.delegate = self
    }
    
    func showEditing(_ sender: UIBarButtonItem)
    {
        if(self.isEditingProfile == true) {
            print("MyAccountVC> currently editing, send update and then turn editing off")
            self.isEditingProfile = false
            fullnameText.isEnabled = false
            emailText.isEnabled = false
            phoneText.isEnabled = false
            settleF2fDetailsText.isEnabled = false
            settleSfAddressText.isEnabled = false
            self.navigationItem.rightBarButtonItem?.title = "編輯"
            
            print("MyAccountVC>> send update profile request to server...")
            var settle_f2f_enable = "false"
            if settleF2fSwitch.isOn {
                settle_f2f_enable = "true"
            }
            var settle_sf_enable = "false"
            if settleSfSwitch.isOn {
                settle_sf_enable = "true"
            }
            updateUserProfile(username: user.username, password: user.password!,
                              fullname: fullnameText.text!, email: emailText.text!, phone: phoneText.text!,
                              settle_f2f_enable: settle_f2f_enable,
                              settle_f2f_details: settleF2fDetailsText.text!,
                              settle_sf_enable: settle_sf_enable,
                              settle_sf_area: "",   //TBA
                              settle_sf_sfid: "",
                              settle_sf_address: settleSfAddressText.text!,
                              completion: {(user: User) -> () in
                print("MyAccountVC>> callback, username: ")
                print(user.username)
                let alert = UIAlertController(title: "提示", message: "用戶資料已更新成功。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            })
        } else {
            print("MyAccountVC> currently not editing, turn editing on")
            self.isEditingProfile = true;
            fullnameText.isEnabled = true
            emailText.isEnabled = true
            phoneText.isEnabled = true
            settleF2fDetailsText.isEnabled = true
            settleSfAddressText.isEnabled = true
            self.navigationItem.rightBarButtonItem?.title = "完成"
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
