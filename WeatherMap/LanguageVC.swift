//
//  LanguageVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-07-10.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class LanguageVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var languages = [Languages]()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let row1 = Languages(language: "English", selector: true)
        let row2 = Languages(language: "Spanish", selector: false)
        languages.append(row1)
        languages.append(row2)
        
        UserDefaults.standard.register(defaults: ["setEnglish" : true])
        UserDefaults.standard.register(defaults: ["setSpanish" : false])
        readDefaults()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "languages", for: indexPath) as? LanguagesCell {
            let language = languages[indexPath.row]
            cell.configureCell(languages: language)
            return cell
        } else {
            return LanguagesCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.languages[0].selector = true
            self.languages[1].selector = false
            Singleton.sharedInstance.languageSelected = "English"
            tableView.reloadData()
            defaults.set("English", forKey: "Language")
            defaults.set(true, forKey: "setEnglish")
            defaults.set(false, forKey: "setSpanish")
        } else if indexPath.row == 1 {
            self.languages[0].selector = false
            self.languages[1].selector = true
            Singleton.sharedInstance.languageSelected = "Spanish"
            tableView.reloadData()
            defaults.set("Spanish", forKey: "Language")
            defaults.set(false, forKey: "setEnglish")
            defaults.set(true, forKey: "setSpanish")
        }
    }
    
    
    func readDefaults() {
        self.languages[0].selector = defaults.bool(forKey: "setEnglish")
        self.languages[1].selector = defaults.bool(forKey: "setSpanish")
    }
    
    @IBAction func backPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "unwindSegueToSettings", sender: self)
    }
    
}
