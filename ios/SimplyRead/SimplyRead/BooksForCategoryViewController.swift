//
//  BooksForCategoryViewController.swift
//  SimplyRead
//
//  Created by jim on 26/9/2017.
//
//

import UIKit

class BooksForCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var category: String?
    var books = [Book]()

    @IBOutlet weak var categoryLabel: UINavigationItem!
    @IBOutlet var tableView: UITableView!

    var bottomBookId: String?
    var reachedEndOfItems = false
    var refreshControl: UIRefreshControl!

    let cellReuseIdentifier = "cell"
    let cellIdentifier = "BookTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categoryLabel.title = "{" + category! + "}"
        
        print("BooksForCategoryViewControler>> start loadBooks")
//        loadBooksForCategory(category: category!, completion: {(books: [Book]) -> () in
        loadBooks(isIdle: "Yes", category: category!, completion: {(books: [Book]) -> () in
            print("BooksForCategoryViewControler>> callback")
            self.books = books
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        })
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
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
        cell.ourPriceLabel.text = book.sr_price
        
        //set holder
        cell.holderLabel.text = book.hold_by
        
        // Check if the last row number is the same as the last current data element
        if bottomBookId == nil || book.mongoObjectId! < bottomBookId! {
            bottomBookId = book.mongoObjectId
        }
        if indexPath.row == self.books.count - 1 {  //if reach bottom
            self.loadMore(bottomBookId: bottomBookId!)
        }

        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadMore(bottomBookId: String){
        print("BookTableVC>> load more...")
        guard !self.reachedEndOfItems else {
            return
        }
        
        // query the db on a background thread
        DispatchQueue.global(qos: .background).async {
            // query the database...
            loadBooks(bottomBookId: bottomBookId, isIdle: "Yes", category: self.category, completion: {(booksNew: [Book]) -> () in
                self.books.append(contentsOf: booksNew)
                // update UITableView with new batch of items on main thread after query finishes
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
    }
    

}
