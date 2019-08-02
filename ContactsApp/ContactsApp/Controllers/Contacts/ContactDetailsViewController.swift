//
//  ContactDetailsViewController.swift
//  ContactsApp
//
//  Created by STDev on 8/2/19.
//  Copyright © 2019 STDev. All rights reserved.
//

import UIKit

protocol ContactDetailsViewControllerDelegate: class {
    func didAddContact(_ controller: ContactDetailsViewController)
    func willAddContact(_ controller: ContactDetailsViewController)
    func didEditContact(_ controller: ContactDetailsViewController)
}

class ContactDetailsViewController: BaseViewController {
    enum ControllerType {
        case addNewContact
        case edit
        case view
    }
    
    weak var delegate: ContactDetailsViewControllerDelegate?
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var doneButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var controllerType: ControllerType = .addNewContact {
        didSet {
            self.set(type: controllerType)
        }
    }
    var contact: Contact?
    var image: UIImage?
    
    fileprivate var cells: [UITableViewCell] = []
    fileprivate var didEditContact: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "TextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "textFieldCell")
        self.tableView.register(UINib(nibName: "ImageTableViewCell", bundle: nil), forCellReuseIdentifier: "imageCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tap)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backPressed))
    }
    
    fileprivate func set(type: ControllerType) {
        switch type {
        case .addNewContact:
            self.doneButton.isHidden = false
        case .view:
            self.doneButton.isHidden = true
        case .edit:
            self.doneButton.isHidden = false
        }
        configComponents()
    }
    
    fileprivate func configComponents() {
        cells = []
        
        let setupTextFieldCell = { () -> TextFieldTableViewCell in
            let textFieldCell = self.tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as! TextFieldTableViewCell
            switch self.controllerType {
            case .addNewContact:
                textFieldCell.set(style: .editable)
            case .edit:
                textFieldCell.set(style: .editable)
            case .view:
                textFieldCell.set(style: .nonEditable)
            }
            return textFieldCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell") as! ImageTableViewCell
        cell.profileImageView.image = image
        self.cells.append(cell)
        
        let firstNameCell = setupTextFieldCell()
        firstNameCell.cellType = .firstName(name: contact?.firstName ?? "")
        self.cells.append(firstNameCell)
        
        let lastNameCell = setupTextFieldCell()
        lastNameCell.cellType = .lastName(name: contact?.lastName ?? "")
        self.cells.append(lastNameCell)
        
        let phoneCell = setupTextFieldCell()
        phoneCell.cellType = .phone(text: contact?.phone ?? "")
        self.cells.append(phoneCell)
        
        let emailCell = setupTextFieldCell()
        emailCell.cellType = .email(text: contact?.email ?? "")
        self.cells.append(emailCell)
        
        let notesCell = setupTextFieldCell()
        notesCell.cellType = .notes(text: contact?.notes ?? "")
        self.cells.append(notesCell)
        
        self.tableView.reloadData()
    }
    
    @IBAction func doneButtonPressed() {
        self.view.endEditing(true)
        guard let details = getContactFullDetails(), !details.isEmpty else {
            return
        }
        
        self.activityIndicatorController.show(inSuperview: self.view)
        switch self.controllerType {
        case .addNewContact:
            self.delegate?.willAddContact(self)
            APIService.shared.addContact(details: details) { (data, error) in
                guard let _ = data, error == nil else {
                    return
                }
                    
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    self.delegate?.didAddContact(self)
                }
            }
        case .edit:
            APIService.shared.updateContact(details: details, id: contact!.id!) { (data, error) in
                guard let _ = data, error == nil else {
                    return
                }
                
                APIService.shared.getContact(id: self.contact!.id!) { (contact, error) in
                    guard let contact = contact, error == nil else {
                        return
                    }
                    self.contact = contact
                    self.didEditContact = true
                    
                    DispatchQueue.main.async {
                        self.controllerType = .view
                        self.activityIndicatorController.hide()
                    }
                }
            }
        case .view:
            break
        }
    }
    
    private func getContactFullDetails() -> [String: Any]? {
        var details: [String: Any] = [:]
        for cell in cells {
            if let cell = cell as? TextFieldTableViewCell {
                if cell.textField.text?.isEmpty ?? true {
                    return nil
                } else {
                    switch cell.cellType! {
                    case .firstName:
                        details["firstName"] = cell.textField.text
                    case .lastName:
                        details["lastName"] = cell.textField.text
                    case .phone:
                        details["phone"] = cell.textField.text
                    case .email:
                        details["email"] = cell.textField.text
                    case .notes:
                        details["notes"] = cell.textField.text
                    }
                }
            }
        }
        details["images"] = ["aa"]
        return details
    }
}

//MARK: Action handlers
extension ContactDetailsViewController {
    @objc func keyboardWillHide() {
        self.doneButtonBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        self.doneButtonBottomConstraint.constant = keyboardHeight
        self.view.layoutIfNeeded()
    }
    
    @objc func handleTap() {
        self.view.endEditing(true)
    }
    
    @objc func editPressed() {
        self.controllerType = .edit
    }
    
    @objc func backPressed() {
        if didEditContact {
            self.delegate?.didEditContact(self)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
}

//MARK: Tableview delegate & datasource
extension ContactDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
}
