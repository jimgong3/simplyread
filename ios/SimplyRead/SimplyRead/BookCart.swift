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
    var totalPrice = 0.0
    var totalDeposit = 0.0
    var totalShippingFee = 0.0
    
    var orders = [String: Int]()            //number of books for each holder
    var shippingFees = [String: Double]()   //shipping fee by holder
    
    func addBook(book: Book){
        print("BuyBookCart>> add book")
        books.append(book)
        print("BuyBookCart>> book added to cart, # of books: \(books.count)")
        
        numBooks += 1
        totalPrice += Double((book.currentCopy?.price)!)!
        if book.deposit != nil && book.deposit != "NaN"{
            totalDeposit += Double(book.deposit!)!
        }
        
        var holder = book.currentCopy?.hold_by
        if orders[holder!] == nil {
            orders[holder!] = 1
            shippingFees[holder!] = 18.0
            totalShippingFee += shippingFees[holder!]!
        } else {
            orders[holder!] = orders[holder!]! + 1
            if orders[holder!]! <= 2 {
                shippingFees[holder!] = 18.0
            } else {
                totalShippingFee -= shippingFees[holder!]!
                shippingFees[holder!] = Double(18 + 7 * (orders[holder!]! - 2))
                totalShippingFee += shippingFees[holder!]!
            }
        }
        
//        if book.shipping_fee != nil && book.shipping_fee != "NaN"{
//            totalShippingFee += Int(book.shipping_fee!)!
//        }
        //calculate shipping fee
        //first two books: $18
        //each book after: $7
//        if numBooks <= 2 {
//            totalShippingFee = 18.0
//        } else {
//            totalShippingFee = Double(18 + 7 * (numBooks-2))
//        }
    }
    
    func dropBook(book: Book){
        print("BuyBookCart>> drop book")
        for i in 0...books.count-1 {
            if books[i].isbn! == book.isbn
                && books[i].currentCopy?.owner == book.currentCopy?.owner
                && books[i].currentCopy?.price == book.currentCopy?.price {
                books.remove(at: i)
                break
            }
        }
        print("BuyBookCart>> book dropped from cart, # of books: \(books.count)")
        
        numBooks -= 1
        totalPrice -= Double((book.currentCopy?.price)!)!
        if book.deposit != nil && book.deposit != "NaN"{
            totalDeposit -= Double(book.deposit!)!
        }
        
        var holder = book.currentCopy?.hold_by
        if orders[holder!] == nil {
            //shall not happen
        } else {
            orders[holder!] = orders[holder!]! - 1
            if orders[holder!]! == 0 {
                shippingFees[holder!] = 0.0
                totalShippingFee -= 18.0
            } else if orders[holder!]! == 1 {
                shippingFees[holder!] = 18.0
                totalShippingFee -= 0.0
            } else if orders[holder!]! == 2 {
                shippingFees[holder!] = 18.0
                totalShippingFee -= 18.0
            } else {
                totalShippingFee -= shippingFees[holder!]!
                shippingFees[holder!] = Double(18 + 7 * (orders[holder!]! - 2))
                totalShippingFee += shippingFees[holder!]!
            }
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
