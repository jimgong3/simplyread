//
//  BuyBookCartViewController.swift
//  SimplyRead
//
//  Created by jim on 16/9/2017.
//
//

import UIKit

class BuyBookCartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var books = [Book]()

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var numBooks: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var totalDeposit: UILabel!
    @IBOutlet weak var totalShipping: UILabel!
    @IBOutlet weak var totalFee: UILabel!
    
    
    let cellReuseIdentifier = "cell"
    let cellIdentifier = "BookTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        books = BuyBookCart.sharedInstance.books
        numBooks.text = books.count.description
        
        //calculate total price & deposit
//        var price = 0
//        var deposit = 0
//        for book in books {
//            price += Int(book.our_price_hkd!)!
//            deposit += Int(book.deposit!)!
//        }
        totalPrice.text = BuyBookCart.sharedInstance.totalPrice.description
        totalDeposit.text = BuyBookCart.sharedInstance.totalDeposit.description
        totalShipping.text = BuyBookCart.sharedInstance.totalShippingFee.description
        
        let grandTotal = BuyBookCart.sharedInstance.totalPrice + BuyBookCart.sharedInstance.totalDeposit + BuyBookCart.sharedInstance.totalShippingFee
        totalFee.text = grandTotal.description
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        var rightButton = UIBarButtonItem(title: "編輯", style: UIBarButtonItemStyle.plain, target: self, action: Selector(("showEditing:")))
        self.navigationItem.rightBarButtonItem = rightButton
    }

    func showEditing(_ sender: UIBarButtonItem)
    {
        if(self.tableView.isEditing == true) {
            self.tableView.isEditing = false
            self.navigationItem.rightBarButtonItem?.title = "編輯"
        } else {
            self.tableView.isEditing = true
            self.navigationItem.rightBarButtonItem?.title = "完成"
        }
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            BuyBookCart.sharedInstance.dropBook(book: books[indexPath.row])
            totalPrice.text = BuyBookCart.sharedInstance.totalPrice.description
            totalDeposit.text = BuyBookCart.sharedInstance.totalDeposit.description
            totalShipping.text = BuyBookCart.sharedInstance.totalShippingFee.description
            books.remove(at: indexPath.row)
            
            let grandTotal = BuyBookCart.sharedInstance.totalPrice + BuyBookCart.sharedInstance.totalDeposit + BuyBookCart.sharedInstance.totalShippingFee
            totalFee.text = grandTotal.description

            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BookTableViewCell else {
            fatalError("the dequeued cell is not an instance of BookTableViewCell")
        }
        
        let book = books[indexPath.row]
        //        print ("BookTableViewController>> set table cell: " + "(\(book.title))")
        
        // set title
        cell.titleLabel.text = book.title
        // set authors
        cell.authorLabel.text = book.authorsText
        // set images
        if (book.photo != nil){
            cell.photoImageView.image = book.photo
        }
        else if (book.image_medium_url != nil) {
            let url = URL(string: book.image_medium_url!)
            getDataFromUrl(url: url!) { (data, response, error) in
                guard let data = data, error == nil else { return }
                //                print(response?.suggestedFilename ?? url?.lastPathComponent)
                //                print("BookTableViewController>> image download Finished")
                DispatchQueue.main.async() { () -> Void in
                    cell.photoImageView.image = UIImage(data: data)
                }
            }
        }
        // set price
        cell.ourPriceLabel.text = book.sr_price
        cell.depositLabel.text = book.sr_deposit
        
        //set holder
        cell.holderLabel.text = book.hold_by
        
        return cell
    }
    
    
    @IBAction func done(_ sender: Any) {
        print("BuyBookCartViewController>> done")
        self.performSegue(withIdentifier: "donateSelectComplete1", sender: self)
    }

    @IBAction func submitOrder(_ sender: Any) {
        print("BuyBookCartVC>> submit order start...")
        
        let me = Me.sharedInstance.user
        
        var bookArray = [Any]()
        for i in 0...books.count-1 {
            let book = books[i]
            let bookJson: [String: Any] = [
                "title": book.title,
                "owner": book.owner,
                "price": book.sr_price ?? 0,
                "deposit": book.sr_deposit ?? 0,
                "hold_by": book.hold_by ?? "n/a"
            ]
            bookArray.append(bookJson)
        }
        
        let orderJson: [String: Any] = [
            "username": me?.username ?? "n/a",
            "email": me?.email,
            "books": bookArray,
            "num_books": books.count.description,
            "sum_deposit": BuyBookCart.sharedInstance.totalDeposit.description,
            "sum_price": BuyBookCart.sharedInstance.totalPrice.description,
            "shipping_fee": BuyBookCart.sharedInstance.totalShippingFee,
            "total": BuyBookCart.sharedInstance.total
        ]
        print("BuyBookCartVC>> orderJson: ")
        var details = jsonToString(json: orderJson as AnyObject)
        
        SimplyRead.submitOrder(details: details, completion: {(result: String) -> () in
            print("BuyBookCartVC>>> callback...")
            let alert = UIAlertController(title: "提示", message: "訂單已提交。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func jsonToString(json: AnyObject) -> String {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            print(convertedString ?? "defaultvalue")
            var result = convertedString ?? "defaultvalue"
            return result
        } catch let myJSONError {
            print(myJSONError)
            return "error"
        }
        
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
