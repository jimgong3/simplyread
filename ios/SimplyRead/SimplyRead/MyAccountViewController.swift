//
//  MyAccountViewController.swift
//  SimplyRead
//
//  Created by jim on 7/9/2017.
//
//

import UIKit

class MyAccountViewController: UIViewController {

    var user: User!
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var fullnameText: UITextField!
    @IBOutlet weak var postAddressText: UITextField!
    @IBOutlet weak var balanceText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // get user
        let srTableBarController = self.tabBarController as! SRTabBarController
        user = srTableBarController.user
        
        // set attributes
        if let user = user{
            usernameText.text = user.username
            fullnameText.text = user.fullname
            postAddressText.text = user.post_address
            balanceText.text = user.balance
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
