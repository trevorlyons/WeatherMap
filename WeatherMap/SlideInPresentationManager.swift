//
//  SlideInPresentationManager.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-05.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

enum PresentationDirection {
    case bottom
    case left
    case right
    case top
}

class SlideInPresentationManager: NSObject {
    
    var direction = PresentationDirection.right

}

extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(presentedViewController: presented, presenting: presenting, direction: direction)
        return presentationController
    }
    
}
