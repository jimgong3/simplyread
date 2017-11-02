//
//  DonateSingleBookNotFoundViewController.swift
//  SimplyRead
//
//  Created by jim on 12/9/2017.
//
//

import UIKit
//import BarcodeScanner

class DonateSingleBookNotFoundViewController: UIViewController,
        UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    var isbn: String?   //set via scan, if possible
    var book: Book?
    var user: User?
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak internal var titleText: UITextField!
    @IBOutlet weak internal var authorText: UITextField!
    @IBOutlet weak internal var isbnText: UITextField!
    @IBOutlet weak var depositText: UITextField!
    @IBOutlet weak var priceText: UITextField!

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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tapgesture = UITapGestureRecognizer(target: self, action: Selector("selectImage2"))
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(tapgesture)
        
        titleText.delegate = self
        authorText.delegate = self
        isbnText.delegate = self
        depositText.delegate = self
        priceText.delegate = self
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        if isbn != nil {
            isbnText.text = isbn
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // set default category
//        let cat = book?.category
        let row = 0
//        if cat != nil {
//            for i in 0...categoryData.count-1 {
//                if categoryData[i] == cat {
//                    row = i
//                    break
//                }
//            }
//        }
        categoryPicker.selectRow(row, inComponent: 0, animated: true)
        if row != 0 {
            self.category = categoryData[row]
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
//        print("DonateSingleBookNotFound>> select image")
//        
//        titleText.resignFirstResponder()
//        authorText.resignFirstResponder()
//        isbnText.resignFirstResponder()
//
//        let imagePickerController = UIImagePickerController()
//        
//        imagePickerController.sourceType = .photoLibrary
//        imagePickerController.delegate = self
//        
//        present(imagePickerController, animated: true, completion: nil)
//    
//    }

    func selectImage2() {
//        print("DonateSingleBookNotFound>> select image")
        
        titleText.resignFirstResponder()
        authorText.resignFirstResponder()
        isbnText.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        photoImageView.image = selectedImage
        dismiss(animated: true, completion: nil)

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Obsolete
    @IBAction func addToCart(_ sender: Any) {
        print("DonateSingleBookNotFoundViewController>> add to donate book cart ")
        
        //construct the book object
        let book = Book(title: titleText.text!)
        book?.authors = [String]()
        book?.authors?.append(authorText.text!)
        book?.authorsText = authorText.text!
        book?.isbn = isbnText.text
        book?.photo = photoImageView.image
        
        DonateBookCart.sharedInstance.addBook(book: book!)
        
        //show notification
        let alert = UIAlertController(title: "提示", message: "已經放入漂書籃。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
        
        //send requet to server: add new book
//        addNewBook2(title: (book?.title)!, author: (book?.authorsText)!, isbn: (book?.isbn)!, completion: {(book: Book) -> () in
//            print("addNewBook2>> callback")
            //anything else
//        })
//        addNewBookImage(isbn: (book?.isbn)!, image: (book?.photo)!, completion: {(book: Book) -> () in
//            print("addNewBook>> callback")
            //anything else
//        })

    }
    
    @IBAction func complete(_ sender: Any) {
        print("DonateSingleBookViewController>> choose complete, start upload... ")
//        self.performSegue(withIdentifier: "donateSelectComplete2", sender: self)
        
/*
        //construct the book object
        let book = Book(title: titleText.text!)
        book?.authors = [String]()
        book?.authors?.append(authorText.text!)
        book?.authorsText = authorText.text!
        book?.isbn = isbnText.text
        book?.photo = photoImageView.image
*/		
		let title = titleText.text
		let authors = authorText.text
		let isbn = isbnText.text
        let category = self.category
        let price = Int(priceText.text)
        let deposit = Int(depositText.text)
        let user = Me.sharedInstance.user;
		
        if user == nil || user?.username == "" {
            let alert = UIAlertController(title: "提示", message: "請先登錄。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        } else if title == nil || title == "" {
            let alert = UIAlertController(title: "提示", message: "圖書標題不能留空。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
		} else if deposit == nil || price == nil {
			let alert = UIAlertController(title: "提示", message: "按金和借閱價須為整數。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
		} else {
            print("DonateSingleBookNotFoundVC>> send requet to server to add new book...")
            addNewBook2(title: title!, author: authors, isbn: isbn,
                        username: user?.username!, 
						category: category,
                        price: price!, deposit: deposit!,
						completion: {(book: Book) -> () in
                
				print("addNewBook2>> callback")
				if book.title != "" {		
					print("DonateSingleBookNotFoundVC>> book upload success, upload image...")				
				    addNewBookImage(isbn: (book.isbn)!, image: (book.photo)!,
									completion: {(book: Book) -> () in
						print("DonateSingleBookNotFoundVC>> callback")
						//anything else...
					})

					//show notification
					let alert = UIAlertController(title: "提示", message: "圖書上傳成功。", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
						NSLog("The \"OK\" alert occured.")
					}))
					self.present(alert, animated: true, completion: nil)
				} else {
					print("addNewBook2>> book upload fail")				
					//show notification
					let alert = UIAlertController(title: "提示", message: "上傳不成功，請檢查圖書資料。", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: NSLocalizedString("好", comment: "Default action"), style: .`default`, handler: { _ in
						NSLog("The \"OK\" alert occured.")
					}))
					self.present(alert, animated: true, completion: nil)
				}
            })
        }
    }	
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleText.resignFirstResponder()
        authorText.resignFirstResponder()
        isbnText.resignFirstResponder()
        depositText.resignFirstResponder()
        priceText.resignFirstResponder()
        return true
    }
    
    // set picker view
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


}

//
//extension DonateSingleBookNotFoundViewController: BarcodeScannerCodeDelegate {
//    
//    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
//        print("DonateSingleBookNotFoundViewController>> get captured code back")
//        print("DonateSingleBookNotFoundViewController>> code: " + code)
//        print("DonateSingleBookNotFoundViewController>> type: " + type)
//        
//        // send request to search book with isbn/code
//        searchAddBook(isbn: code, completion: {(book: Book) -> () in
//            print("DonateSingleBookNotFoundViewController>> callback, book: ")
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

//extension DonateSingleBookNotFoundViewController: BarcodeScannerErrorDelegate {
//    
//    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
//        print("DonateSingleBookNotFoundViewController>> get scanner error")
//        print(error)
//    }
//}
//
//extension DonateSingleBookNotFoundViewController: BarcodeScannerDismissalDelegate {
//    
//    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
//        print("DonateSingleBookNotFoundViewController>> user click close")
//        controller.dismiss(animated: true, completion: nil)
//    }
//}

