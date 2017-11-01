//
//  DonateBookViewController.swift
//  SimplyRead
//
//  Created by jim on 8/9/2017.
//
//

import UIKit
//import BarcodeScanner

class DonateBookViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var isbn: String?
    var book: Book?
    var user: User?

    var books = [Book]()
    
    @IBOutlet var tableView: UITableView!
    
    let cellReuseIdentifier = "cell"
    let cellIdentifier = "BookTableViewCell"
	
	var topBookId: String?
    var bottomBookId: String?
    var reachedEndOfItems = false

	var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // get user
        user = Me.sharedInstance.user
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self

        print("BookTabelViewControler>> start loadBooks")
        print("BookTableVC>> load all books")
        if user != nil {
            loadBooks(owner: user?.username, completion: {(books: [Book]) -> () in
//                print("BookTableViewController>> callback")
                self.books = books
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            })
        }

		 // pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "加載最新圖書...")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
	
	
    func refresh(sender: AnyObject) {
        // Code to refresh table view
        print("DonateBookVC>> refresh...")
        
        self.loadLatest(topBookId: topBookId!)
        refreshControl.endRefreshing()
    }
    
    func loadLatest(topBookId: String){
        print("DonateBookVC>> load latest...")
        
        // query the db on a background thread
        DispatchQueue.global(qos: .background).async {
            loadBooks(topBookId: topBookId, owner: self.user?.username, completion: {(booksNew: [Book]) -> () in
//                print("DonateBookVC>> callback")
                self.books.insert(contentsOf: booksNew, at: 0)
                
                // update UITableView with new batch of items on main thread after query finishes
                DispatchQueue.main.async {
                    // reload the table view
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            })
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
        if (book.image_url != nil) {
            //            var url = URL(string: book.image_medium_url!)
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
        // set our price
        cell.ourPriceLabel.text = book.sr_price!   //price of each copy
        cell.depositLabel.text = book.sr_deposit!   //price of each copy
        
        //set status
        cell.statusLabel.text = book.status
        
        // Check if the last row number is the same as the last current data element
        if bottomBookId == nil || book.mongoObjectId! < bottomBookId! {
            bottomBookId = book.mongoObjectId
        }
        if indexPath.row == self.books.count - 1 {  //if reach bottom
            self.loadMore(bottomBookId: bottomBookId!)
        }

        // update topBookId
		if topBookId == nil || book.mongoObjectId! > topBookId! {
            topBookId = book.mongoObjectId
        }
		
        return cell
    }

    func loadMore(bottomBookId: String){
        print("BookTableVC>> load more...")
        
        // don't bother doing another db query if already have everything
        guard !self.reachedEndOfItems else {
            return
        }
        
        // query the db on a background thread
        DispatchQueue.global(qos: .background).async {
            
            // query the database...
            loadBooks(bottomBookId: bottomBookId, owner: self.user?.username, completion: {(booksNew: [Book]) -> () in
//                print("DonateBookVC>> callback")
                self.books.append(contentsOf: booksNew)
                
                // update UITableView with new batch of items on main thread after query finishes
                DispatchQueue.main.async {
                    // reload the table view
                    self.tableView.reloadData()
                    // check if this was the last of the data
                    if booksNew.count == 0 {
                        self.reachedEndOfItems = true
                        print("reached end of data. ")
                    }
                }
            })
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
//        guard let singleBookViewController = segue.destination as? SingleBookViewController else {
//            fatalError("unexpected destination: \(segue.destination)")
//        }
//        singleBookViewController.book = book
//        singleBookViewController.user = user
        
        if let donateSingleBookViewController = segue.destination as? DonateSingleBookViewController {
            print("DonateBookViewController>> book found")
            donateSingleBookViewController.book = book
            donateSingleBookViewController.user = user
        }
        else if let donateSingleBookNotFoundViewController = segue.destination as? DonateSingleBookNotFoundViewController {
            print("DonateBookViewController>> book not found")
            donateSingleBookNotFoundViewController.isbn = isbn
            donateSingleBookNotFoundViewController.user = user
        }
        else {
            fatalError("unexpected destination: \(segue.destination)")
        }
    }
    

    @IBAction func startScan(_ sender: UIButton) {
        print("DonateBookViewController>> start scan")
        
        let controller = BarcodeScannerController()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        
        present(controller, animated: true, completion: nil)
    }

    //for testing
    @IBAction func simulateScanComplete(_ sender: UIButton) {
        print("DonateBookViewController>> simulate scan complete")
        
        //prepare dummy data
        let code = "7300226531"
        searchAddBook(isbn: code, completion: {(book: Book) -> () in
            print("DonateBookViewController>> callback, book: ")
            print(book.title)
            self.book = book

            self.performSegue(withIdentifier: "donateSearchBook", sender: self)
        })
    }

    //for testing
    @IBAction func simulateScanCompleteNotFound(_ sender: UIButton) {
        print("DonateBookViewController>> simulate scan complete, book not found")
        self.isbn = "7300226531"
        self.performSegue(withIdentifier: "donateSearchBookNotFound", sender: self)
    }

}

extension DonateBookViewController: BarcodeScannerCodeDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        print("DonateBookViewController>> get captured code back")
        print("DonateBookViewController>> code: " + code)
        print("DonateBookViewController>> type: " + type)
        
        self.isbn = code
        
         // send request to search book with isbn/code
//        searchAddBook(isbn: code, completion: {(book: Book) -> () in
        searchBook(isbn: code, completion: {(book: Book) -> () in
            if(!book.title.isEmpty){    //book found
                print("DonateBookViewController>> callback, book: ")
                print(book.title)
                self.book = book
                self.performSegue(withIdentifier: "donateSearchBook", sender: self)
            }
            else{   //book not found
                print("DonateBookViewController>> callback, book not found ")
                self.performSegue(withIdentifier: "donateSearchBookNotFound", sender: self)
            }
        })

        let delayTime = DispatchTime.now() +
            Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            // if found
            controller.dismiss(animated: true, completion: nil)
            // if not found
            // controller.resetWithError(message: "Error message")
        }
        
       
    }
}

extension DonateBookViewController: BarcodeScannerErrorDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print("DonateBookViewController>> get scanner error")
        print(error)
    }
}

extension DonateBookViewController: BarcodeScannerDismissalDelegate {
    
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        print("DonateBookViewController>> user click close")
        controller.dismiss(animated: true, completion: nil)
    }
}

