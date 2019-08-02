//
//  AppCoordinator.swift
//  ContactsApp
//
//  Created by STDev on 8/2/19.
//  Copyright © 2019 STDev. All rights reserved.
//

import Foundation
import UIKit

class AppCoordinator {
    func start() {
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            let controller = ContactsViewController(nibName: "ContactsViewController", bundle: nil)
            let navController = UINavigationController(rootViewController: controller)
            
            if let window = UIApplication.shared.keyWindow {
                window.rootViewController = navController
            }
        } else {
            let controller = LoginViewController(nibName: "LoginViewController", bundle: nil)
            controller.delegate = self
            
            if let window = UIApplication.shared.keyWindow {
                window.rootViewController = controller
            }
        }
    }
}

extension AppCoordinator: LoginViewControllerDelegate {
    func didFinishLogin(_ controller: LoginViewController) {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        self.start()
    }
}
