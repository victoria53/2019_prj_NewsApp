//
//  ProfileViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 30.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Firebase
import TransitionButton
import Loaf

// TODO: Add settings (e.g. include country getting news by category?)

class ProfileViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editDetailsButton: UIButton!
    @IBOutlet weak var editInterestsButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var signOutButton: TransitionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureElements()
        
        // Observe for changes in the first name of the user
        UserDefaults.standard.addObserver(self, forKeyPath: "firstname", options: .new, context: nil)
    }
    
    override func didReceiveMemoryWarning() {
        UserDefaults.standard.removeObserver(self, forKeyPath: "firstname")
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "firstname")
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        signOutButton.startAnimation()
        
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { (_) in
            self.signOut()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.signOutButton.stopAnimation()
        })
        present(alertController, animated: true, completion: nil)
    }

}

// MARK: Helper Functions
extension ProfileViewController {
    func signOut() -> Void {
        Authentication.signOut { [unowned self] (isSingedOut) in
            if isSingedOut {
                self.signOutButton.stopAnimation(animationStyle: .expand) { [unowned self] in
                    // navigating to Auth views
                    
                    UserRepository.removeUserInfo()
                    
                    let authVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.authVC) as! UINavigationController
                    authVC.isNavigationBarHidden = true
                    
                    self.view.window?.rootViewController = authVC
                    self.view.window?.makeKeyAndVisible()
                }
            } else {
                self.signOutButton.stopAnimation()
                self.showMessage("Could not sign out!", style: .error)
            }
        }
    }
    
    func configureElements() {
        titleLabel.text = "Hello " + (UserRepository.fetch(key: .firstname) as! String)
        
        styleSecondaryButton(editDetailsButton)
        styleSecondaryButton(editInterestsButton)
        styleSecondaryButton(changePasswordButton)
        styleDangerButton(signOutButton)
    }
    
    func showMessage(_ message: String, style: Loaf.State) {
        Loaf(message, state: style, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
    }
}

// MARK: User Defaults Observer Handler
extension ProfileViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if UserRepository.checkFor(key: .firstname) {
            self.titleLabel.text = "Hello " + (UserRepository.fetch(key: .firstname) as! String)
        }
    }
}
