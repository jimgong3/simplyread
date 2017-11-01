//
//  BookListViewController.swift
//  SimplyRead
//
//  Created by jim on 29/8/2017.
//
//

import UIKit
import os.log

class BookTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    //MARK: Properties
    var books = [Book]()
    var user: User?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var isSearchingMode = false
    var isTypingMode = false
    
    let cellReuseIdentifier = "cell"
    let cellIdentifier = "BookTableViewCell"
    
    var idleBooksFromUser: String?

    // number of items to be fetched each time (i.e., database LIMIT)
    let itemsPerBatch = 20
    // _id of the book at bottom/top
    var topBookId: String?
    var bottomBookId: String?
    // a flag for when all database items have already been loaded
    var reachedEndOfItems = false
    
    var refreshControl: UIRefreshControl!

    //MARK: Private Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("BookTabelViewControler>> start loadBooks")
        if(idleBooksFromUser != nil){
            self.title = idleBooksFromUser! + "的書架"
        }
        
        print("BookTableVC>> load books start...")
        loadBooks(hold_by: idleBooksFromUser, isIdle: "Yes", completion: {(books: [Book]) -> () in
            print("BookTableViewController>> callback")
            self.books = books
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        })
//        } else {
//            print("BookTableVC>> load idle books from user")
//            self.title = idleBooksFromUser! + "的書架"
//            loadIdleBooksForUser2(username: idleBooksFromUser!, completion: {(books: [Book]) -> () in
//			loadBooks(hold_by: idleBooksFromUser!, isIdle: "Yes", completion: {(books: [Book]) -> () in
//                print("BookTableViewController>> callback")
//                self.books = books
//                DispatchQueue.main.async{
//                    self.tableView.reloadData()
//                }
//            })
//        }

        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        // get user
        let srTableBarController = self.tabBarController as! SRTabBarController
        user = srTableBarController.user
        
        // pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "加載最新圖書...")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    func refresh(sender: AnyObject) {
        // Code to refresh table view
        print("BookTableVC>> refresh...")
        
        //do something here...
        if(idleBooksFromUser == nil){   //only need refresh when load all books (instead of from a specific user)
            self.loadLatest(topBookId: topBookId!)
            refreshControl.endRefreshing()
        }
    }
    
    func loadLatest(topBookId: String){
        print("BookTableVC>> load latest...")
        
        // query the db on a background thread
        DispatchQueue.global(qos: .background).async {
            loadBooks(topBookId: topBookId, hold_by: self.idleBooksFromUser, isIdle: "Yes", completion: {(booksNew: [Book]) -> () in
                print("BookTableViewController>> callback")
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
        // set summary
        cell.summaryLabel.text = book.summary
        // set our price
//        cell.ourPriceLabel.text = book.our_price_hkd
        cell.ourPriceLabel.text = book.sr_price!   //price of each copy
        
        //set holder
//        cell.holderLabel.text = (book.currentCopy?.hold_by)!
        cell.holderLabel.text = book.hold_by
        
        // Check if the last row number is the same as the last current data element
        if bottomBookId == nil || book.mongoObjectId! < bottomBookId! {
            bottomBookId = book.mongoObjectId
        }
        if indexPath.row == self.books.count - 1 {  //if reach bottom
            if isSearchingMode {
                print("BookTableVC>> searching mode - all results already returned")
                self.reachedEndOfItems = true
            } else {
                print("BookTableVC>> load more...")
                self.loadMore(bottomBookId: bottomBookId!)
            }
        }
        
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
            
            // determine the range of data items to fetch
//            var thisBatchOfItems: [Book]?
            
            // query the database...
            loadBooks(bottomBookId: bottomBookId, hold_by: self.idleBooksFromUser, isIdle: "Yes", completion: {(booksNew: [Book]) -> () in
                print("BookTableViewController>> callback")
                self.books.append(contentsOf: booksNew)
              
                // update UITableView with new batch of items on main thread after query finishes
                DispatchQueue.main.async {
//                    if let newItems = thisBatchOfItems {
                        // append the new items to the data source for the table view
//                        self.books.append(contentsOf: newItems)
                        // reload the table view
                        self.tableView.reloadData()
                        // check if this was the last of the data
                        if booksNew.count == 0 {
                            self.reachedEndOfItems = true
                            print("reached end of data. ")
                        }
//                    }
                }
            })
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        guard let singleBookViewController = segue.destination as? SingleBookViewController else {
                fatalError("unexpected destination: \(segue.destination)")
        }
        
        guard let selectedBookCell = sender as? BookTableViewCell else {
            fatalError("unexpected sender: \(String(describing: sender))")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedBookCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let selectedBook = books[indexPath.row]
        singleBookViewController.book = selectedBook
        singleBookViewController.user = user
    }
    
    // MARK: Restful
      
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        print("BookTableVC>> search button clicked...")
        searchBar.resignFirstResponder()
        self.isSearchingMode = true
        
        let keyword = searchBar.text
        print("BookTableVC>> search keyword: " + keyword!)
        
        search(keyword: keyword, isIdle: "Yes", completion: {(books: [Book]) -> () in
            print("BookTableViewController>> callback from search...")
            self.books = books
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        })
    }
    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
//        print("BookTableVC>> cancel button clicked...")
//        searchBar.resignFirstResponder()
//        self.isSearchingMode = false
//        searchBar.text = ""
//    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("BookTableVC>> text did change start...")
        self.isTypingMode = true
        
        if searchBar.text == "" {    //tap "clear"
            print("BookTableVC>> user tap clear...")
            searchBar.resignFirstResponder()
            searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
            self.isSearchingMode = false
            self.isTypingMode = false

            loadBooks(isIdle: "Yes", completion: {(books: [Book]) -> () in
                print("BookTableViewController>> callback")
                self.books = books
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            })
        }
    }

}

