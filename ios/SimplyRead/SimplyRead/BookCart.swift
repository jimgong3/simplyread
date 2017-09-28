//
//  DonateBookCart.swift
//  SimplyRead
//
//  Created by jim on 16/9/2017.
//
//

import Foundation

class BuyBookCart {
    static let sharedInstance = BuyBookCart()
    
    var books = [Book]()
    var numBooks = 0
    var totalPrice = 0
    var totalDeposit = 0
    var totalShippingFee = 0
    
    func addBook(book: Book){
        print("BuyBookCart>> add book")
        books.append(book)
        print("BuyBookCart>> book added to cart, # of books: \(books.count)")
        
        numBooks += 1
        totalPrice += Int(book.our_price_hkd!)!
        if book.deposit != nil && book.deposit != "NaN"{
            totalDeposit += Int(book.deposit!)!
        }
        
//        if book.shipping_fee != nil && book.shipping_fee != "NaN"{
//            totalShippingFee += Int(book.shipping_fee!)!
//        }
        //calculate shipping fee
        //first two books: $18
        //each book after: $7
        if numBooks <= 2 {
            totalShippingFee = 18
        } else {
            totalShippingFee = 18 + 7 * (numBooks-2)
        }
    }
}


class DonateBookCart {
    static let sharedInstance = DonateBookCart()
    
    var books = [Book]()
    var numBooks = 0

    func addBook(book: Book){
        print("DonateBookCart>> add book")
        books.append(book)
        print("DonateBookCart>> book added to cart, # of books: \(books.count)")
   
        numBooks += 1
    }
}
