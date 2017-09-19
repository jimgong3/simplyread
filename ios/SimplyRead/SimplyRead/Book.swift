//
//  Book.swift
//  SimplyRead
//
//  Created by jim on 29/8/2017.
//
//

import UIKit

class Book {
    
    //MARK: Properties
    var title: String
    var authors: [String]?
    var authorsText: String?
    var photo: UIImage?
    var image_url: String?
    var image_small_url: String?
    var image_medium_url: String?
    var image_large_url: String?
    var publisher: String?
    var price: String?
    var summary: String?
    var pages: String?
    
    var our_price_hkd: String?
    var deposit: String?
    var shipping_fee: String?
    var num_total: String?
    var num_onshelf: String?
    
    var isbn: String?   //used when donate book

    init?(title: String){
        self.title = title
    }
    
    init?(json: [String: Any]) {
        print("Book>> create book from json")
        print(json)
        
        // get title
        let title = json["title"] as? String
        self.title = title!
        
        // get authors
        let authorsJson = json["author"] as? [String]
        if authorsJson != nil {
//            guard authorsJson != nil else {
//                fatalError("Book>> cannot find author from book json: \(json)")
//                return
//            }
            var authors = [String]()
            var authorsText = ""
            var count = 0
            for author in authorsJson! {
                authors.append(author)
                if count>0 {
                    authorsText += ", "
                }
                authorsText += author
                count += 1
            }
            self.authors = authors
            self.authorsText = authorsText
        }
        
        // get images
        self.image_url = json["image"] as? String
        let imagesJson = json["images"] as? [String: Any]
        let image_small_url = imagesJson?["small"] as? String
        let image_medium_url = imagesJson?["medium"] as? String
        let image_large_url = imagesJson?["large"] as? String
        self.image_small_url = image_small_url
        self.image_medium_url = image_medium_url
        self.image_large_url = image_large_url
        
        // get publisher
        let publisher = json["publisher"] as? String
        self.publisher = publisher
        
        // get summary
        let summary = json["summary"] as? String
        self.summary = summary
        
        // get price
        self.price = json["price"] as? String
        
        // get our price
        self.our_price_hkd = json["our_price_hkd"] as? String
        
        // get pages
        self.pages = json["pages"] as? String
        
        // get shipping fee
        self.shipping_fee = json["shipping_fee"] as? String
        
        // get deposit
        self.deposit = json["deposit"] as? String

        // get number of copies
        self.num_total = json["num_total"] as? String
        self.num_onshelf = json["num_onshelf"] as? String

//        print ("Book>> parse book complete for " + "(\title)")
    }

    
//    init?(title: String, authors: [String]?, photo: UIImage?){
//        
//        guard !title.isEmpty else {
//            return nil
//        }
//        
//        self.title = title
//        self.authors = authors
//        self.photo = photo
//    }
    
 
//    init?(json: [String: Any]) {
//        guard let title = json["title"] as? String,
//            let authorsJSON = json["authors"] as? [String]
//            else {
//                return nil
//        }
//        
//        var authors = [String]()
//        for author in authorsJSON {
//            authors.append(author)
//        }
//        
//        self.title = title
//        self.authors = authors
//    }
    
}
