//
//  SettingsVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-04.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import MessageUI

protocol HandleRemoveAnnotations {
    func removeAndReplaceAnnotations()
}

class SettingsVC: UIViewController, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    
    // MARK: IBOutlets
    
    @IBOutlet weak var unitTypeLbl: UILabel!
    @IBOutlet weak var langSelectedLbl: UILabel!
    
    
    // MARK: Variables and Constants
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    var removeAnnotationsDelegate: HandleRemoveAnnotations!
    
    
    // MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unitTypeLbl.text = Singleton.sharedInstance.unitSelectedOWM.capitalized
        langSelectedLbl.text = Singleton.sharedInstance.languageSelected
    }
    
    
    // MARK: Mail feedback functions
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("Weather Map Feedback")
        mail.setToRecipients(["weather.maps.feedback@gmail.com"])
        return mail
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Override transition segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? MeasurementUnitsVC {
            slideInTransitioningDelegate.direction = .right
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        } else if let controller = segue.destination as? AcknowledgementsVC {
            slideInTransitioningDelegate.direction = .right
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        } else if let controller = segue.destination as? LanguageVC {
            slideInTransitioningDelegate.direction = .right
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        } else if let controller = segue.destination as? PrivacyPolicyVC {
            slideInTransitioningDelegate.direction = .right
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        } else if let controller = segue.destination as? TutorialVC {
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            controller.preferredContentSize = CGSize(width: screenWidth*0.9, height: screenHeight*0.7)
            let popoverController = controller.popoverPresentationController
            if popoverController != nil {
                popoverController!.delegate = self
                popoverController!.sourceView = self.view
                popoverController!.sourceRect = CGRect(x: self.view.bounds.midX, y: (self.view.bounds.midY)+50, width: 0, height: 0)
                popoverController!.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    
    // MARK: App rating function
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId + "?action=write-review&mt=8") else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    
    // MARK: IBActions
    
    @IBAction func acknoledgementsPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "acknowledgementsSegue", sender: self)
    }
    
    @IBAction func rateAppPressed(_ sender: UITapGestureRecognizer) {
        rateApp(appId: "id1265065569") { success in
            print("RateApp \(success)")
        }
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
    
    @IBAction func tutorialPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "Tutorial", sender: self)
    }
    
    @IBAction func privacyPolicyPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "toPrivacyPolicy", sender: self)
    }
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
        unitTypeLbl.text = Singleton.sharedInstance.unitSelectedOWM.capitalized
        langSelectedLbl.text = Singleton.sharedInstance.languageSelected
        removeAnnotationsDelegate!.removeAndReplaceAnnotations()
    }
    

}
