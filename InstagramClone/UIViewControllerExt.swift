//
//  UIViewControllerExt.swift
//  InstagramClone
//
//  Created by Lova Krishna on 24/04/20.
//  Copyright © 2020 Lova Krishna. All rights reserved.
//

import UIKit


fileprivate let overlayViewTag = 999
fileprivate let activityIndicatorTag = 1000

extension UIViewController {

    func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                completion(options[index])
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentActionSheet(title: String?, message: String?, actionTitles:[String?], actionStyle:[UIAlertAction.Style], actions:[((UIAlertAction) -> Void)?], vc: UIViewController) {
         let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
         for (index, title) in actionTitles.enumerated() {
              let action = UIAlertAction(title: title, style: actionStyle[index], handler: actions[index])
              alert.addAction(action)
         }
         vc.present(alert, animated: true, completion: nil)
    }
    
    // UIActivityIndicatorView  
    
    public func displayActivityIndicator(shouldDisplay: Bool) -> Void {
           if shouldDisplay {
               setActivityIndicator()
           } else {
               removeActivityIndicator()
           }
       }

       private func setActivityIndicator() -> Void {
           guard !isDisplayingActivityIndicatorOverlay() else { return }
           guard let parentViewForOverlay = navigationController?.view ?? view else { return }

           //configure overlay
           let overlay = UIView()
           overlay.translatesAutoresizingMaskIntoConstraints = false
           overlay.backgroundColor = UIColor.black
           overlay.alpha = 0.5
           overlay.tag = overlayViewTag

           //configure activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
           activityIndicator.translatesAutoresizingMaskIntoConstraints = false
           activityIndicator.tag = activityIndicatorTag

           //add subviews
           overlay.addSubview(activityIndicator)
           parentViewForOverlay.addSubview(overlay)

           //add overlay constraints
           overlay.heightAnchor.constraint(equalTo: parentViewForOverlay.heightAnchor).isActive = true
           overlay.widthAnchor.constraint(equalTo: parentViewForOverlay.widthAnchor).isActive = true

           //add indicator constraints
           activityIndicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor).isActive = true
           activityIndicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor).isActive = true

           //animate indicator
           activityIndicator.startAnimating()
       }

       private func removeActivityIndicator() -> Void {
           let activityIndicator = getActivityIndicator()

           if let overlayView = getOverlayView() {
               UIView.animate(withDuration: 0.2, animations: {
                   overlayView.alpha = 0.0
                   activityIndicator?.stopAnimating()
               }) { (finished) in
                   activityIndicator?.removeFromSuperview()
                   overlayView.removeFromSuperview()
               }
           }
       }

       private func isDisplayingActivityIndicatorOverlay() -> Bool {
           if let _ = getActivityIndicator(), let _ = getOverlayView() {
               return true
           }
           return false
       }

       private func getActivityIndicator() -> UIActivityIndicatorView? {
           return (navigationController?.view.viewWithTag(activityIndicatorTag) ?? view.viewWithTag(activityIndicatorTag)) as? UIActivityIndicatorView
       }

       private func getOverlayView() -> UIView? {
           return navigationController?.view.viewWithTag(overlayViewTag) ?? view.viewWithTag(overlayViewTag)
       }
    
    
    
    
    // ToHideKeyboardOnTapOnView
    func setupToHideKeyboardOnTapOnView()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))

        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

