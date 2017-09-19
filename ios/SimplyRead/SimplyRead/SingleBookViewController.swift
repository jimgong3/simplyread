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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ourPriceLabel: UILabel!
    @IBOutlet weak var summaryText: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let book = book {
            // show title
            titleLabel.text = book.title
            
            // show authors
            authorsLabel.text = book.authorsText
            
            // show images
            if (book.image_url != nil) {
                var url = URL(string: book.image_url!)
                getDataFromUrl(url: url!) { (data, response, error) in
                    guard let data = data, error == nil else { return }
                    print(response?.suggestedFilename ?? url?.lastPathComponent)
                    print("SingleBookViewController>> image download finished")
                    DispatchQueue.main.async() { () -> Void in
                        self.photoImageView.image = UIImage(data: data)
                    }
                }
            }
            
            // show publisher
            publisherLabel.text = book.publisher
            
            // show prices
            priceLabel.text = book.price
            ourPriceLabel.text = book.our_price_hkd?.description
            
            // show summary
            summaryText.text = book.summary
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
        
        guard let buyBookCartViewController = segue.destination as? BuyBookCartViewController else {
            fatalError("unexpected destination: \(segue.destination)")
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

}