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
        
        guard let srTabBarController = segue.destination as?
            SRTabBarController else {
                fatalError("unexpected destination: \(segue.destination)")
        }
        srTabBarController.user = user
        Me.sharedInstance.user = user

    }
    
    @IBAction func startLogin(_ sender: Any) {
        var username = usernameText.text
        var password = passwordText.text
        login2(username: username!, password: password!, completion: {(user: User) -> () in
            print("LoginViewController>> callback, user: ")
            self.user = user
            print(user.username)
            
            print("LoginViewController>> set global, user: ")
            Me.sharedInstance.user = user
        
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "loginSuccess", sender: self)
            }
        })

    }

    @IBAction func lookAround(_ sender: Any) {
            print("LoginViewController>> look around ")
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "loginSuccess", sender: self)
            }
    }

}
