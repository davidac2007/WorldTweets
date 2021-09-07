//
//  SignInViewController.swift
//  WorldTweets
//
//  Created by David Avendaño on 07/09/21.
//

import UIKit
import NotificationBannerSwift

class SignInViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Actions
    
    @IBAction func signInButtonAction(){
        performLogin()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Private Methods
    private func setupUI(){
        
        signInButton.layer.cornerRadius = 25

    }
    
    private func performLogin(){
        
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Enter a valid email",style: .warning).show()
            
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else{
            NotificationBanner(title: "Error", subtitle: "The password is incorrect",style: .warning).show()
            return
        }
        
    }
    
    
}
