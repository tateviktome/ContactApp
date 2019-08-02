//
//  ContactsViewController.swift
//  ContactsApp
//
//  Created by STDev on 8/2/19.
//  Copyright © 2019 STDev. All rights reserved.
//

import UIKit

class ContactsViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var contacts: [Contact] = []
    fileprivate var contactImages: [String: UIImage] = [:]
    fileprivate var pendingTasks: [URLSessionDataTask] = []
    fileprivate var group = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "default")
        
        self.getContacts()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddContact))
    }
    
    func getContacts() {
        self.activityIndicatorController.show(inSuperview: self.view)
        
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            let task = APIService.shared.getContacts { [weak self] (contacts, error) in
                defer { self?.group.leave() }
                guard let contacts = contacts, error == nil else {
                    return
                }
                
                self?.contacts = contacts
                
                for contact in contacts {
                    self?.group.enter()
                    let imageTask = APIService.shared.getImage(id: contact.id!, callback: { (data, error) in
                        defer { self?.group.leave() }
                        guard let data = data, error == nil else {
                            return
                        }
                        
                        if let image = UIImage(data: data) {
                            self?.contactImages["\(contact.id!)"] = image
                        }
                    })
                    self?.pendingTasks.append(imageTask!)
                }
            }
            self.pendingTasks.append(task!)
        }
        
        group.notify(queue: .main) {
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicatorController.hide()
                self?.tableView.reloadData()
                for task in (self?.pendingTasks ?? []) {
                    task.cancel()
                }
                self?.pendingTasks.removeAll()
            }
        }
    }
    
    @objc func didTapAddContact() {
        let contr = ContactDetailsViewController(nibName: "ContactDetailsViewController", bundle: nil)
        contr.delegate = self
        self.present(contr, animated: true, completion: nil)
        contr.loadViewIfNeeded()
        contr.controllerType = .addNewContact
    }
    
    func deleteContact(withId id: String) {
        self.activityIndicatorController.show(inSuperview: self.view)
        APIService.shared.deleteContact(id: id) { (data, error) in
            guard let _ = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.getContacts()
            }
        }
    }
}

//MARK: tableview delegate & datasource
extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default") as! ContactTableViewCell
        cell.config(withContact: contacts[indexPath.row], image: contactImages["\(contacts[indexPath.row].id!)"])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contr = ContactDetailsViewController(nibName: "ContactDetailsViewController", bundle: nil)
        contr.contact = contacts[indexPath.row]
        contr.image = contactImages["\(contacts[indexPath.row].id!)"]
        contr.delegate = self
        self.navigationController?.pushViewController(contr, animated: true)
        contr.loadViewIfNeeded()
        contr.controllerType = .view
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.deleteContact(withId: self.contacts[indexPath.row].id!)
        }
        return [deleteAction]
    }
}

//MARK: detailscontroller delegate
extension ContactsViewController: ContactDetailsViewControllerDelegate {
    func didEditContact(_ controller: ContactDetailsViewController) {
        self.getContacts()
    }
    
    func willAddContact(_ controller: ContactDetailsViewController) {
        for task in pendingTasks {
            task.cancel()
        }
        pendingTasks.removeAll()
    }
    
    func didAddContact(_ controller: ContactDetailsViewController) {
        self.getContacts()
    }
}
