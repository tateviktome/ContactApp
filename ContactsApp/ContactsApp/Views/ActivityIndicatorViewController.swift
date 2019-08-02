//
//  ActivityIndicatorViewController.swift
//  ContactsApp
//
//  Created by STDev on 8/2/19.
//  Copyright © 2019 STDev. All rights reserved.
//

import UIKit

class ActivityIndicatorViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func show(inSuperview superview: UIView) {
        for subview in self.view.subviews where subview == self.view {
            return
        }
        self.loadViewIfNeeded()
        activityIndicator.startAnimating()
        superview.addSubview(self.view)
        
        self.view.topAnchor.constraint(equalTo: superview.topAnchor)
        self.view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        self.view.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        self.view.leadingAnchor.constraint(equalTo: superview.leadingAnchor)
    }
    
    func hide() {
        activityIndicator.stopAnimating()
        self.view.removeFromSuperview()
    }
}
