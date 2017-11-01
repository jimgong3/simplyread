//
//  DonateSingleBookViewController.swift
//  SimplyRead
//
//  Created by jim on 11/9/2017.
//
//

import UIKit
//import BarcodeScanner

class DonateSingleBookViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    var book: Book?
    var user: User?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    let categoryData = [
        "未分類",
        "商管理財",
        "流行文學",
        "心理勵志",
        "飲食文化",
        "旅遊地理",
        "生活趣味",
        "養生保健",
        "親子教育",
        "宗教哲學",
        "兒童圖書"
    ]
    var category: String?
    
//    var isbnCode: String?
//    @IBOutlet weak var depositText: UITextField!
    @IBOutlet weak var rentText: UITextField!
    @IBOutlet weak var depositText: UITextField!
    
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
                let url = URL(string: book.image_large_url!)
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
            publisherLabel.text = book.publisher
            // show original price
            originalPriceLabel.text = book.price
            
        }

        rentText.delegate = self
        depositText.delegate = self
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // set default category
        let cat = book?.category
        var row = 0
        if cat != nil {
            for i in 0...categoryData.count-1 {
                if categoryData[i] == cat {
                    row = i
                    break
                }
            }
        }
        categoryPicker.selectRow(row, inComponent: 0, animated: true)
        if row != 0 {
            self.category = categoryData[row]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        rentText.resignFirstResponder()
        depositText.resignFirstResponder()
        return true
    }

    

    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.category = categoryData[row]
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
        
        let isbn = self.book?.isbn
//        let user = Me.sharedInstance.user
        let owner = Me.sharedInstance.user?.username
        var category = ""
        if self.category != nil {
            category = self.category!
        }
        let price = Int(rentText.text!)
        let deposit = Int(depositText.text!)
        
		let user = Me.sharedInstance.user;
		if user == nil || user?.username == "" {
            let alert = UIAlertController(title: "提示", message: "請先登錄。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)		
		}
        else if price == nil || deposit == nil {
            let alert = UIAlertController(title: "提示", message: "按金和借閱價須為整數。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            addBookByIsbn(isbn: isbn!, title: "", category: category, owner: owner!, price: price!, deposit: deposit!,
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

