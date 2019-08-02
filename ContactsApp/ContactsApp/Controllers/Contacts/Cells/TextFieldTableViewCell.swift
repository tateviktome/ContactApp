//
//  TextFieldTableViewCell.swift
//  ContactsApp
//
//  Created by STDev on 8/2/19.
//  Copyright © 2019 STDev. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    enum Style {
        case editable
        case nonEditable
    }
    
    enum CellType {
        case firstName(name: String)
        case lastName(name: String)
        case phone(text: String)
        case email(text: String)
        case notes(text: String)
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var cellType: CellType! {
        didSet {
            self.set(cellType: cellType)
        }
    }
    
    func set(style: Style) {
        switch style {
        case .editable:
            self.textField.isUserInteractionEnabled = true
            self.textField.layer.borderColor = UIColor.gray.cgColor
            self.textField.layer.borderWidth = 1.0
        case .nonEditable:
            self.textField.isUserInteractionEnabled = false
            self.textField.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    fileprivate func set(cellType: CellType) {
        let setTexts = { (labelText: String, fieldText: String) in
            self.label.text = labelText
            self.textField.text = fieldText
        }
        switch cellType {
        case .email(let text):
            setTexts("Email", text)
        case .firstName(let name):
            setTexts("First name", name)
        case .lastName(let name):
            setTexts("Last name", name)
        case .notes(let text):
            setTexts("Notes", text)
        case .phone(let text):
            setTexts("Phone", text)
        }
    }
}
