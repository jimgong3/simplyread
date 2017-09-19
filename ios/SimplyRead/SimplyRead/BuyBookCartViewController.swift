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
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
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
            var url = URL(string: book.image_medium_url!)
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
        cell.ourPriceLabel.text = book.our_price_hkd
        cell.depositLabel.text = book.deposit
        
        return cell
    }
    
    @IBAction func done(_ sender: Any) {
        print("BuyBookCartViewController>> done")
        self.performSegue(withIdentifier: "donateSelectComplete1", sender: self)
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
