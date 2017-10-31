//
//  MyOrderDetailsViewController.swift
//  SimplyRead
//
//  Created by jim on 31/10/2017.
//
//

import UIKit

class MyOrderDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var order: Order?
    var isBuyOrder: Bool?
    var isDeliverOrder: Bool?
    var books = [Book]()

    @IBOutlet var tableView: UITableView!
    
    let cellReuseIdentifier = "cell"
    let cellIdentifier = "BookTableViewCell"

    @IBOutlet weak var numBooks: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var totalDeposit: UILabel!
    @IBOutlet weak var totalShipping: UILabel!
    @IBOutlet weak var totalFee: UILabel!
    
    @IBOutlet weak var confirmDelivered: UIButton!
    @IBOutlet weak var confirmReceived: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if order != nil {
            books = (order?.books)!
        }
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        numBooks.text = order?.num_books
        totalPrice.text = order?.sum_price
        totalDeposit.text = order?.sum_deposit
        totalShipping.text = order?.shipping_fee
        totalFee.text = order?.total

        if isBuyOrder != nil && isBuyOrder! {
            confirmDelivered.isEnabled = false
        } else if isDeliverOrder != nil && isDeliverOrder! {
            confirmReceived.isEnabled = false
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
        else if (book.image_url != nil) {
            let url = URL(string: book.image_url!)
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
