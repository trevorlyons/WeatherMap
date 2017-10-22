//
//  PrivacyPolicyVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-09-08.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class PrivacyPolicyVC: UIViewController {
    
    
    // MARK: IBOutlets
    
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var textFieldHeightConstraint: NSLayoutConstraint!
    
    
    // MARK: Variables and Constants
    
    var textFromFile = String()
    
    
    // MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.text = textFromFile
        if let path = Bundle.main.path(forResource: "WeatherMapsPrivacyPolicy", ofType: "txt") {
            if let contents = try? String(contentsOfFile: path) {
                textField.text = contents
            }
        }
    }
    
    
    // MARK: viewDidLayoutSubviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textFieldHeightConstraint.constant = textField.contentSize.height
        textField.layoutIfNeeded()
    }
    
    
    // MARK: IBActions
    
    @IBAction func backBtnPressed(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
}
