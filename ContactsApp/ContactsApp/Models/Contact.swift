//
//  Contact.swift
//  ContactsApp
//
//  Created by STDev on 8/2/19.
//  Copyright © 2019 STDev. All rights reserved.
//

import Foundation

class Contact: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName
        case lastName
        case phone
        case email
        case notes
        case images
    }
    
    var id: String?
    var firstName: String?
    var lastName: String?
    var phone: String?
    var email: String?
    var notes: String?
    var images: [String]?
}
