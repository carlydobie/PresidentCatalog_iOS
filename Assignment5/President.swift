//
//  President.swift
//  Assignment5
//
//  Created by Carly Dobie on 11/4/20.
//  Copyright © 2020 Carly Dobie. All rights reserved.
//

import Foundation

// Stores information on each president
class President: Decodable {
    
    // Attributes for each president in property list
    var name = ""
    var number = 0
    var startDate = ""
    var endDate = ""
    var nickname = ""
    var party = ""
    var url = ""
    
    // Keys to decode each attribute in property list and store in President a object
    private enum CodingKeys: String, CodingKey {
        case name = "Name"
        case number = "Number"
        case startDate = "Start Date"
        case endDate = "End Date"
        case nickname = "Nickname"
        case party = "Political Party"
        case url = "URL"
    }
    
    // Initialization
    init(name: String, number: Int, startDate: String, endDate: String, nickname: String, party: String, url: String) {
        self.name = name
        self.number = number
        self.startDate = startDate
        self.endDate = endDate
        self.nickname = nickname
        self.party = party
        self.url = url
    }
}
