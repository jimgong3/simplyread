//
//  User.swift
//  SimplyRead
//
//  Created by jim on 3/9/2017.
//
//

import Foundation

class User {
    
    //MARK: Properties
    var username: String
    var password: String?
    var fullname: String?
    var email: String?
    var post_address: String?
    var balance: String?
    
    init?(username: String){
//        guard !username.isEmpty else{
//            return nil
//        }
        self.username = username
    }
    
    init?(json: [String: Any]){
//        print("User>> create user from json")
        
        self.username = json["username"] as! String
        self.password = json["password"] as? String
        self.fullname = json["fullname"] as? String
        self.email = json["email"] as? String
        self.post_address = json["post_address"] as? String
        self.balance = json["balance"] as? String
        
//        print("User>>: user created from json")
    }
    
}
