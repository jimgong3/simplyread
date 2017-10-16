//
//  LoginViewController.swift
//  SimplyRead
//
//  Created by jim on 29/8/2017.
//
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var user: User?
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameText.delegate = self
        passwordText.delegate = self

        // check if remembered username & password
        usernameText.text = UserDefaults.standard.string(forKey: "username")
        passwordText.text = UserDefaults.standard.string(forKey: "password")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameText.resignFirstResponder()
        passwordText.resignFirstResponder()
        return true
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        print ("LoginViewController>> prepare")
//        var username = usernameText.text
//        var password = passwordText.text
//        login(username: username!, password: password!, completion: {(user: User) -> () in
//            print("LoginViewController>> callback, user: ")
//            self.user = user
//            print(user.username)
        
//            self.performSegue(withIdentifier: "loginSuccess", sender: nil)
//        })
        
//        if let srTabBarController = segue.destination as? SRTabBarController {
//            srTabBarController.user = user  //obsolete
//            Me.sharedInstance.user = user
//        }

    }
    
    @IBAction func startLogin(_ sender: Any) {
        let username = usernameText.text
        let password = passwordText.text
        login3(username: username!, password: password!, completion: {(user: User) -> () in
            print("LoginViewController>> callback, username: ")
//            self.user = user
            print(user.username)
            
            if user.username == "" {
                print("Login: login fail")
                
                let alert = UIAlertController(title: "提示", message: "登錄不成功，請檢查登錄名和密碼。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
//                print("LoginViewController>> set global, user: ")
                Me.sharedInstance.user = user
                
                DispatchQueue.main.async(){
                    self.performSegue(withIdentifier: "loginSuccess", sender: self)
                }
                
                //remember username & password
                UserDefaults.standard.set(username, forKey: "username")
                UserDefaults.standard.set(password, forKey: "password")
            }
        })

    }

    @IBAction func lookAround(_ sender: Any) {
            print("LoginViewController>> look around ")
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "loginSuccess", sender: self)
            }
    }

//    @IBAction func register(_ sender: Any) {
//        print("LoginViewController>> register ")
//        DispatchQueue.main.async(){
//            self.performSegue(withIdentifier: "register", sender: self)
//        }
//    }

}
