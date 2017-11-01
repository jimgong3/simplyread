//
//  MyCashbookViewController.swift
//  SimplyRead
//
//  Created by jim on 22/10/2017.
//
//

import UIKit

class MyCashbookViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var user: User?
    var cashTxns = [CashTxn]()
    
    @IBOutlet weak var balanceText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let cellReuseIdentifier = "cell"
    let cellIdentifier = "MyCashbookTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
		let username = UserDefaults.standard.string(forKey: "username")
        let password = UserDefaults.standard.string(forKey: "password")
		
		print("MyCashBookVC>> login again to get the latest balance... ")
		login3(username: username!, password: password!, completion: {(user: User) -> () in
            print("MyCashBookVC>> callback, username: ")
            print(user.username)
            if user.username == "" {
                print("MyCashBookVC>> login fail")                
            } else {
                Me.sharedInstance.user = user
                // set attributes
					balanceText.text = user?.balance?.description
					queryCashTxns(username: (user?.username)!, completion: {(cashTxns: [CashTxn]) -> () in
						print("MyCashbookViewController>> callback")
						self.cashTxns = cashTxns
						DispatchQueue.main.async{
							self.tableView.reloadData()
						}
					})
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cashTxns.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MyCashbookTableViewCell else {
            fatalError("the dequeued cell is not an instance of MyCashbookTableViewCell")
        }
        
        let cashTxn = cashTxns[indexPath.row]
        //        print ("BookTableViewController>> set table cell: " + "(\(book.title))")
        
        // set details

        let dateStr = cashTxn.date!
        let index = dateStr.index(dateStr.startIndex, offsetBy: 10) //show yyyy-mm-dd, 10 digits
        let dateStr2 = dateStr.substring(to: index)

        cell.dateLabel.text = dateStr2
        cell.amountLabel.text = cashTxn.amount
        cell.descriptionLabel.text = cashTxn.description
        
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
