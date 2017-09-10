//
//  PrivacyPolicyVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-09-08.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class PrivacyPolicyVC: UIViewController {

    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var textFieldHeightConstraint: NSLayoutConstraint!
    
    var textFromFile = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.text = textFromFile
        if let path = Bundle.main.path(forResource: "WeatherMapsPrivacyPolicy", ofType: "txt") {
            if let contents = try? String(contentsOfFile: path) {
                textField.text = contents
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textFieldHeightConstraint.constant = textField.contentSize.height
        textField.layoutIfNeeded()
    }
    
    @IBAction func backBtnPressed(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
}
