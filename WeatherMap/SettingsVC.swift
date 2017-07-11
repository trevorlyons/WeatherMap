//
//  SettingsVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-04.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import MessageUI

class SettingsVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var unitTypeLbl: UILabel!
    @IBOutlet weak var langSelectedLbl: UILabel!
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unitTypeLbl.text = Singleton.sharedInstance.unitSelectedOWM.capitalized
        langSelectedLbl.text = Singleton.sharedInstance.languageSelected
    }
    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("Weather Map Feedback")
        mail.setToRecipients(["trevorjclyons@hotmail.com"])
        return mail
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? MeasurementUnitsVC {
            slideInTransitioningDelegate.direction = .right
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        }
        if let controller = segue.destination as? AcknowledgementsVC {
            slideInTransitioningDelegate.direction = .right
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        }
        if let controller = segue.destination as? LanguageVC {
            slideInTransitioningDelegate.direction = .right
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        }
    }
    
    
    @IBAction func acknoledgementsPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "acknowledgementsSegue", sender: self)
    }
    
    @IBAction func rateAppPressed(_ sender: UITapGestureRecognizer) {
    }
    
    @IBAction func feedbackPressed(_ sender: UITapGestureRecognizer) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            print("email failed")
        }
    }
    
    @IBAction func languagePressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "languageSegue", sender: self)
    }

    @IBAction func measureUnitsPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "unitsSegue", sender: self)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
        unitTypeLbl.text = Singleton.sharedInstance.unitSelectedOWM.capitalized
        langSelectedLbl.text = Singleton.sharedInstance.languageSelected
    }
    

}
