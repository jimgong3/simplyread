//
//  BooksForTagViewController.swift
//  SimplyRead
//
//  Created by jim on 22/9/2017.
//
//

import UIKit

class BooksForTagViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tag: String?
    var books = [Book]()

    @IBOutlet weak var tagLabel: UINavigationItem!
    @IBOutlet var tableView: UITableView!
    
    let cellReuseIdentifier = "cell"
    let cellIdentifier = "BookTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tagLabel.title = "#" + tag!
        
        print("BooksForTagViewControler>> start loadBooks")
        loadBooksForTag(tag: tag!, completion: {(books: [Book]) -> () in
            print("BooksForTagViewControler>> callback")
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
        cell.ourPriceLabel.text = book.our_price_hkd
       
        //set holder
        cell.holderLabel.text = book.hold_by

        return cell
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
        guard let singleBookViewController = segue.destination as? SingleBookViewController else {
            fatalError("unexpected destination: \(segue.destination)")
        }
        
        guard let selectedBookCell = sender as? BookTableViewCell else {
            fatalError("unexpected sender: \(sender)")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedBookCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let selectedBook = books[indexPath.row]
        singleBookViewController.book = selectedBook
    }
    

}
