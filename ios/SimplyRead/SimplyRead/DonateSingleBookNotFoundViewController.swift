//
//  DonateSingleBookNotFoundViewController.swift
//  SimplyRead
//
//  Created by jim on 12/9/2017.
//
//

import UIKit
import BarcodeScanner

class DonateSingleBookNotFoundViewController: UIViewController,
        UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    var book: Book?
    var user: User?
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak internal var titleText: UITextField!
    @IBOutlet weak internal var authorText: UITextField!
    @IBOutlet weak internal var isbnText: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tapgesture = UITapGestureRecognizer(target: self, action: Selector("selectImage2"))
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(tapgesture)
        
        titleText.delegate = self
        authorText.delegate = self
        isbnText.delegate = self
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
    
    
    @IBAction func addToCart(_ sender: Any) {
        print("DonateSingleBookNotFoundViewController>> add to donate book cart ")
        
        //construct the book object
        var book = Book(title: titleText.text!)
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
        addNewBook(title: (book?.title)!, author: (book?.authorsText)!, isbn: (book?.isbn)!, completion: {(book: Book) -> () in
            print("addNewBook>> callback")
            //anything else
        })
        addNewBookImage(isbn: (book?.isbn)!, image: (book?.photo)!, completion: {(book: Book) -> () in
            print("addNewBook>> callback")
            //anything else
        })

    }
    
    @IBAction func complete(_ sender: Any) {
        print("DonateSingleBookViewController>> choose complete ")
        self.performSegue(withIdentifier: "donateSelectComplete2", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleText.resignFirstResponder()
        authorText.resignFirstResponder()
        isbnText.resignFirstResponder()
        return true
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

