//
//  OrderDetailsViewController.swift
//  SimplyRead
//
//  Created by jim on 1/9/2017.
//
//

import UIKit

class OrderDetailsViewController: UIViewController {

//    var book: Book?
//    var user: User?
    
    @IBOutlet weak var postAddressText: UITextField!
    @IBOutlet weak var deliveryOption: UITextField!
    @IBOutlet weak var shippingFee1Label: UILabel!

    @IBOutlet weak var numberBooksLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak var shippingFeeLabel: UILabel!
    @IBOutlet weak var grandTotalLabel: UILabel!
    
    @IBOutlet weak var userBalanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //post address
        let me = Me.sharedInstance.user
        postAddressText.text = me?.post_address
        
//        numberBooksLabel.text = BuyBookCart.sharedInstance.numBooks.description
        
        //fees
        let totalPrice = BuyBookCart.sharedInstance.totalPrice
//        totalPriceLabel.text = totalPrice.description
        let totalDeposit = BuyBookCart.sharedInstance.totalDeposit
//        depositLabel.text = totalDeposit.description
//        
//        let totalShippingFee = BuyBookCart.sharedInstance.totalShippingFee
//        let totalShippingFee = 18   //hardcode for testing
        let totalShippingFee = BuyBookCart.sharedInstance.totalShippingFee
//        shippingFee1Label.text = totalShippingFee.description
//        shippingFeeLabel.text = totalShippingFee.description
        
        let grandTotal = totalPrice + totalDeposit + totalShippingFee
        grandTotalLabel.text = grandTotal.description
        
        //balance
        userBalanceLabel.text = me?.balance
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
