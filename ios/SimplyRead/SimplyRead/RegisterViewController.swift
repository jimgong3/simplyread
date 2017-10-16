//
//  RegisterViewController.swift
//  SimplyRead
//
//  Created by jim on 16/10/2017.
//
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var fullnameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func register(_ sender: Any) {
        let username = usernameText.text
        let password = passwordText.text
        let fullname = fullnameText.text
        let email = emailText.text
        
        print("register: username: " + username! + ", password: " + password!)
        print("register: fullname: " + fullname! + ", email: " + email!)
        
        SimplyRead.register(username: username!, password: password!, fullname: fullname!, email: email!, completion: {(user: User) -> () in
            print("Register>> callback, user: ")
//            print(user.username)
            
            if user.username == "" {
                print("Register: register fail, username exist")
                
                let alert = UIAlertController(title: "提示", message: "登錄名不可用，請使用其他登錄名。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                print("Register: register success, username: " + username!)
                let alert = UIAlertController(title: "提示", message: "註冊成功，請返回上頁面登錄。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    

}
