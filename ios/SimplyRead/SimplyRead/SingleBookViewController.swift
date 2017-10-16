//
//  SingleBookViewController.swift
//  SimplyRead
//
//  Created by jim on 29/8/2017.
//
//

import UIKit

class SingleBookViewController: UIViewController {
    
    //MARK: Properties
    var book: Book?
    var user: User?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ourPriceLabel: UILabel!
//    @IBOutlet weak var summaryText: UITextView!
//    @IBOutlet weak var summaryText: UILabel!
    @IBOutlet weak var summaryText: UITextView!
   
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBOutlet weak var tagsView1: UIStackView!
    @IBOutlet weak var tagsView2: UIStackView!
    
    var tagClicked: String?
    var categoryClicked: String?
    
    @IBOutlet weak var bookshelfButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        summaryText.lineBreakMode = .byWordWrapping
//        summaryText.numberOfLines = 0
        
        if let book = book {
            // show title
            titleLabel.text = book.title
            // show authors
            authorsLabel.text = book.authorsText
            // show images
            var image_url: String?
            if (book.image_large_url != nil) {
                image_url = book.image_large_url
            } else if (book.image_url != nil) {
                image_url = book.image_url
            }
            if (image_url != nil) {
                let url = URL(string: image_url!)
                getDataFromUrl(url: url!) { (data, response, error) in
                    guard let data = data, error == nil else { return }
//                    print(response?.suggestedFilename ?? url?.lastPathComponent)
                    print("SingleBookViewController>> image download finished")
                    DispatchQueue.main.async() { () -> Void in
                        self.photoImageView.image = UIImage(data: data)
                    }
                }
            }
            // show publisher
            var publisherStr: String?
            publisherStr = book.publisher
            if book.lang != nil &&  book.lang == "zh-cn" {
                publisherStr = publisherStr! + "  (簡體字)"
            }
            publisherLabel.text = publisherStr
            
            // show prices
            priceLabel.text = book.price
//            ourPriceLabel.text = book.our_price_hkd?.description
            ourPriceLabel.text = book.currentCopy?.price
            
            // show summary
            summaryText.text = book.summary
//          // auto adjust textview size to show all contents
            let fixedWidth = summaryText.frame.size.width
            summaryText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = summaryText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = summaryText.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            summaryText.frame = newFrame
            
            //show category
            categoryButton.setTitle(book.category, for: .normal)
            categoryButton.addTarget(self, action: #selector(self.clickCategory), for: .touchUpInside)
            
            //show tags
            var count = 0;
            for tag in book.tags! {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
                button.setTitle("#" + tag.name, for: .normal)
                button.setTitleColor(.orange, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize:12)
                button.addTarget(self, action: #selector(self.clickTag), for: .touchUpInside)
                
                if count<5 {
                    self.tagsView1.addArrangedSubview(button)
                } else {
                    self.tagsView2.addArrangedSubview(button)
                }
                count += 1
            }
            if count<5 {    //add dummy tags to look better
                for _ in 1...(5-count) {
                    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
                    button.setTitle("    ", for: .normal)
                    button.setTitleColor(.orange, for: .normal)
                    button.titleLabel?.font = UIFont.systemFont(ofSize:12)
                    button.addTarget(self, action: #selector(self.clickTag), for: .touchUpInside)
                    self.tagsView1.addArrangedSubview(button)
                }
            } else if count<10 {    //add dummy tags to look better
                for _ in 1...(10-count) {
                    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
                    button.setTitle("    ", for: .normal)
                    button.setTitleColor(.orange, for: .normal)
                    button.titleLabel?.font = UIFont.systemFont(ofSize:12)
                    button.addTarget(self, action: #selector(self.clickTag), for: .touchUpInside)
                    self.tagsView2.addArrangedSubview(button)
                }
            }

            // set scrollview size to include all contents
            var  contentRect = CGRect.zero
            for view in self.scrollView.subviews {
                contentRect = contentRect.union(view.frame)
            }
            self.scrollView.contentSize = contentRect.size;

            //set bookshelf name
            bookshelfButton.setTitle((book.currentCopy?.hold_by)! + "的書架", for: .normal)
        }
    }
    
    func clickTag(sender: UIButton!) {
        print("BookCategoriesViewController>> tag tapped")
        var tag = sender.titleLabel?.text
        tag?.remove(at: (tag?.startIndex)!)
        print("tag: \(tag)")
        
        self.tagClicked = tag
        self.performSegue(withIdentifier: "booksForTag", sender: self)
    }

    func clickCategory(sender: UIButton!) {
        print("click category")
        let category = sender.titleLabel?.text
        if category != nil {
            self.categoryClicked = category
            self.performSegue(withIdentifier: "booksForCategory", sender: self)
        } else {
            print("SingleBookVC: book has no category yet")
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
//        guard let buyBookCartViewController = segue.destination as? BuyBookCartViewController else {
//            fatalError("unexpected destination: \(segue.destination)")
//        }
        
        if let booksForTagViewController = segue.destination as? BooksForTagViewController {
            print("BookCategoriesVC>> dest: books for tag")
            booksForTagViewController.tag = tagClicked
        }
        
        if let booksForCategoryViewController = segue.destination as? BooksForCategoryViewController {
            print("BookCategoriesVC>> dest: books for category")
            booksForCategoryViewController.category = categoryClicked
        }

        if let bookTableViewController = segue.destination as? BookTableViewController {
            print("BookCategoriesVC>> dest: book table")
            bookTableViewController.idleBooksFromUser = self.book?.currentCopy?.hold_by
        }

    }
    
    @IBAction func addToCart(_ sender: Any) {
        print("SingleBookViewController>> add to buy book cart ")
        BuyBookCart.sharedInstance.addBook(book: self.book!)
        
        let alert = UIAlertController(title: "提示", message: "已經放入借書籃。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func complete(_ sender: Any) {
        print("SingleBookViewController>> choose complete ")
        self.performSegue(withIdentifier: "selectBookComplete", sender: self)
    }

    @IBAction func bookshelf(_ sender: Any) {
        print("SingleBookViewController>> choose bookshelf ")
        let username = self.book?.currentCopy?.hold_by
        if username != nil {
            self.performSegue(withIdentifier: "ViewIdleBooksForUser", sender: self)
        } else {
            print("SingleBookVC: book has no holder information")
        }
    }

}
