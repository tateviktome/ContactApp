//
//  ContactTableViewCell.swift
//  ContactsApp
//
//  Created by STDev on 8/2/19.
//  Copyright © 2019 STDev. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    func config(withContact contact: Contact, image: UIImage? = nil) {
        self.profileImageView.image = image
        self.nameLabel.text = contact.firstName ?? ""
        self.phoneNumberLabel.text = contact.lastName ?? ""
    }
}
