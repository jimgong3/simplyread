//
//  DonateBookViewController.swift
//  SimplyRead
//
//  Created by jim on 8/9/2017.
//
//

import UIKit
//import BarcodeScanner

class DonateBookViewController: UIViewController {
    
    var isbn: String?
    var book: Book?
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // get user
        let srTableBarController = self.tabBarController as! SRTabBarController
        user = srTableBarController.user
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
        var code = "7300226531"
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

