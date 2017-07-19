//
//  TutorialVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-07-16.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class TutorialVC: UIViewController {

    @IBOutlet weak var textView1: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        textView1 = textView1.bounds
    }
    
    @IBAction func xTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }
}
