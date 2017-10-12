//
//  DonateSingleBookViewController.swift
//  SimplyRead
//
//  Created by jim on 11/9/2017.
//
//

import UIKit
//import BarcodeScanner

class DonateSingleBookViewController: UIViewController {

    var book: Book?
    var user: User?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var publisherLabel: UILabel!
    
//    var isbnCode: String?
//    @IBOutlet weak var depositText: UITextField!
    @IBOutlet weak var rentText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let book = book {
            // show title
            titleLabel.text = book.title
            // show authors
            authorsLabel.text = book.authorsText
            // show images
            if (book.image_medium_url != nil) {
                var url = URL(string: book.image_large_url!)
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
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

//    @IBAction func scanAnother(_ sender: Any) {
//        print("DonateSingleBookViewController>> scan another ")
//    
//        let controller = BarcodeScannerController()
//        controller.codeDelegate = self
//        controller.errorDelegate = self
//        controller.dismissalDelegate = self
//        
//        present(controller, animated: true, completion: nil)
//
//    }

//    @IBAction func addToCart(_ sender: Any) {
//        print("DonateSingleBookViewController>> add to donate book cart ")
//        DonateBookCart.sharedInstance.addBook(book: self.book!)
//        
//        let alert = UIAlertController(title: "提示", message: "已經放入漂書籃。", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
//            NSLog("The \"OK\" alert occured.")
//        }))
//        self.present(alert, animated: true, completion: nil)
//    }

    @IBAction func complete(_ sender: Any) {
        print("DonateSingleBookViewController>> choose complete ")
//        self.performSegue(withIdentifier: "donateSelectComplete1", sender: self)
        
        var isbn = self.book?.isbn
        var owner = Me.sharedInstance.user?.username
        var category = ""   // to be revised
        var price = Double(rentText.text!)     // to be revised
        addBookByIsbn(isbn: isbn!, title: "", category: category, owner: owner!, price: price!,
                      completion: {(book: Book) -> () in
            print("DonateSingleBookViewController>> callback, book: ")
            print(book.title)
            self.book = book
            self.viewDidLoad()  //force refresh data
                        
            let alert = UIAlertController(title: "提示", message: "圖書上傳成功。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        })
    }

}


//extension DonateSingleBookViewController: BarcodeScannerCodeDelegate {
//    
//    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
//        print("DonateSingleBookViewController>> get captured code back")
//        print("DonateSingleBookViewController>> code: " + code)
//        print("DonateSingleBookViewController>> type: " + type)
//        
//        self.isbnCode = code
//        
//        // send request to search book with isbn/code
//        searchAddBook(isbn: code, completion: {(book: Book) -> () in
//            print("DonateSingleBookViewController>> callback, book: ")
//            print(book.title)
//            self.book = book
//            self.viewDidLoad()  //force refresh data
//        })
//        
//        
//        let delayTime = DispatchTime.now() +
//            Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//        DispatchQueue.main.asyncAfter(deadline: delayTime) {
//            // if found
//            controller.dismiss(animated: true, completion: nil)
//            
//            // if not found
//            // controller.resetWithError(message: "Error message")
//        }
//        
//    }
//}
//
//extension DonateSingleBookViewController: BarcodeScannerErrorDelegate {
//    
//    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
//        print("DonateSingleBookViewController>> get scanner error")
//        print(error)
//    }
//}
//
//extension DonateSingleBookViewController: BarcodeScannerDismissalDelegate {
//    
//    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
//        print("DonateSingleBookViewController>> user click close")
//        controller.dismiss(animated: true, completion: nil)
//    }
//}

