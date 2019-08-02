//
//  LoginViewController.swift
//  ContactsApp
//
//  Created by STDev on 8/2/19.
//  Copyright © 2019 STDev. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: class {
    func didFinishLogin(_ controller: LoginViewController)
}

class LoginViewController: UIViewController {
    
    weak var delegate: LoginViewControllerDelegate?
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func doneButtonPressed() {
        guard let emailText = emailTextField.text, let passwordText = passwordTextField.text,
            !emailText.isEmpty, !passwordText.isEmpty else {
            return
        }
        self.delegate?.didFinishLogin(self)
    }
}
