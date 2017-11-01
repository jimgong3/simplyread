//
//  Order.swift
//  SimplyRead
//
//  Created by jim on 23/10/2017.
//
//

import Foundation

class Order{
    var date: String?
    var username: String?
    var email: String?
    var books: [Book]?
    var listOfBooks: String?
    var num_books: String?
    var sum_deposit: String?
    var sum_price: String?
    var shipping_fee: String?
    var total: String?
    var status: String?
    var orderId: String?
    
    init?(json: [String: Any]){
        print("Order>> json: ")
        print(json)
        
        self.date = json["date"] as? String
        self.username = json["username"] as? String
        self.email = json["email"] as? String
        
        var books = [Book]()
        let bookArray = json["books"] as? [Any]
        if (bookArray?.count)!>0 {
            for i in 0...(bookArray?.count)!-1 {
                let bookJson = bookArray?[i] as? [String: Any]
                let b = Book(json: bookJson!)
                books.append(b!)
                
                if self.listOfBooks == nil {
                    self.listOfBooks = b?.title
                } else {
                    self.listOfBooks = self.listOfBooks! + ", " + (b?.title)!
                }
            }
        }
        self.books = books
        
        self.num_books = json["num_books"] as? String
        self.sum_deposit = json["sum_deposit"] as? String
        self.sum_price = json["sum_price"] as? String
        self.shipping_fee = json["shipping_fee"] as? String
        self.total = json["total"] as? String
        self.status = json["status"] as? String
        self.orderId = json["orderId"] as? String
   }

}
