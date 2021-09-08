//
//  SignUpViewController.swift
//  WorldTweets
//
//  Created by David Avendaño on 07/09/21.
//

import UIKit
import NotificationBannerSwift

class SignUpViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    // MARK: - Actions
    
    @IBAction func signUpButtonAction(){
        view.endEditing(true)
        performSignUp()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI(){
        
        signUpButton.layer.cornerRadius = 25

    }
    
    private func performSignUp(){
        
        guard let name = nameTextField.text,
              !name.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Please enter your name",style: .warning).show()
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Enter a valid email",style: .warning).show()
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else{
            NotificationBanner(title: "Error", subtitle: "The password is incorrect",style: .warning).show()
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, confirmPassword == password else{
            NotificationBanner(title: "Error", subtitle: "The passwords doesn't match",style: .warning).show()
            return
        }
        
        // Perform Sign Up
        performSegue(withIdentifier: "showHome", sender: nil)
        
        
    }
}
    
