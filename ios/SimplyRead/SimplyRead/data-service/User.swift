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
    var phone: String?
    var post_address: String?
    var balance: String?
    
    var settleF2fEnable: String?
    var settleF2fDetails: String?
    var settleSfEnable: String?
    var settleSfArea: String?
    var settleSfSfid: String?
    var settleSfAddress: String?
    
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
        self.phone = json["phone"] as? String
        self.post_address = json["post_address"] as? String
        self.balance = json["balance"] as? String
        
        var settleF2f = json["settle_f2f"] as? [String: Any]
        self.settleF2fEnable = settleF2f?["enable"] as? String
        self.settleF2fDetails = settleF2f?["details"] as? String

        var settleSf = json["settle_sf"] as? [String: Any]
        self.settleSfEnable = settleSf?["enable"] as? String
        self.settleSfArea = settleSf?["area"] as? String
        self.settleSfSfid = settleSf?["sfid"] as? String
        self.settleSfAddress = settleSf?["address"] as? String

//        print("User>>: user created from json")
    }
    
}
