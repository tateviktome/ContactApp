//
//  ImageTableViewCell.swift
//  ContactsApp
//
//  Created by STDev on 8/2/19.
//  Copyright © 2019 STDev. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    enum ImageType {
        case edit
        case noEdit
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var chooseImageButton: UIButton!
    
    @IBAction func chooseImageButtonPressed() {
        
    }
}
