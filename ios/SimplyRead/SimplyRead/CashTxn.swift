//
//  CashTxn.swift
//  SimplyRead
//
//  Created by jim on 23/10/2017.
//
//

import Foundation

class CashTxn{
    var date: String?
    var account: String?
    var amount: String?
    var description: String?
    
    init?(json: [String: Any]){
        self.date = json["date"] as? String
        self.account = json["account"] as? String
        self.amount = json["amount"] as? String
        self.description = json["description"] as? String
    }
}
