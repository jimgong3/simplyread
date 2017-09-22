//
//  Tag.swift
//  SimplyRead
//
//  Created by jim on 22/9/2017.
//
//

import Foundation

class Tag {
    var name: String
    var num_books: Int?
    var book_ids: [String]?
    
    init?(name: String){
        self.name = name
    }
    
    init?(json: [String: Any]){
        print("Tag>> create tag from json")
        print(json)
        
        self.name = (json["name"] as? String)!
        self.num_books = (json["num_books"] as? Int)!
        
        let bookIdJson = (json["book_ids"] as? [String])
        for bookId in bookIdJson! {
            self.book_ids?.append(bookId)
        }
    }
    
    
}
