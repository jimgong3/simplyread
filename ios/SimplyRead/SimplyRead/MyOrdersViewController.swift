//
//  MyOrdersViewController.swift
//  SimplyRead
//
//  Created by jim on 23/10/2017.
//
//

import UIKit

class MyOrdersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var user: User?
    var isBuyOrders: Bool?
    var isDeliverOrders: Bool?
    
    var buyOrders = [Order]()
    
    @IBOutlet weak var buyOrdersTableView: UITableView!
    
    let cellReuseIdentifier = "cell"
    let cellIdentifier = "MyOrdersTableViewCell"

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Register the table view cell class and its reuse id
        self.buyOrdersTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        buyOrdersTableView.delegate = self
        buyOrdersTableView.dataSource = self
        
        user = Me.sharedInstance.user;
        if user != nil {
            if isBuyOrders != nil && isBuyOrders! {
                self.title = "借書籃"
                queryBuyOrders(username: (user?.username)!, completion: {(orders: [Order]) -> () in
                    print("MyOrdersViewController>> callback")
                    self.buyOrders = orders
                    DispatchQueue.main.async{
                        self.buyOrdersTableView.reloadData()
                    }
                })
            } else if isDeliverOrders != nil && isDeliverOrders! {
                self.title = "漂書籃"
                queryDeliverOrders(hold_by: (user?.username)!, completion: {(orders: [Order]) -> () in
                    print("MyOrdersViewController>> callback")
                    self.buyOrders = orders
                    DispatchQueue.main.async{
                        self.buyOrdersTableView.reloadData()
                    }
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.buyOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MyOrdersTableViewCell else {
            fatalError("the dequeued cell is not an instance of required")
        }
        
        let order = buyOrders[indexPath.row]
        //        print ("BookTableViewController>> set table cell: " + "(\(book.title))")
        
        // set details
        cell.dateLabel.text = order.date
        cell.statusLabel.text = order.status
        cell.listOfBooksLabel.text = order.listOfBooks
        
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
