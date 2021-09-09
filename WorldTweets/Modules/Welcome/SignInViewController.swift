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
        view.endEditing(true)
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
        
        func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
        }
        
        guard let email = emailTextField.text, !email.isEmpty && isValidEmail(email) else {
            NotificationBanner(title: "Error", subtitle: "Enter a valid email",style: .warning).show()
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else{
            NotificationBanner(title: "Error", subtitle: "The password is incorrect",style: .warning).show()
            return
        }
        
        //    performLogin
        performSegue(withIdentifier: "showHome", sender: nil)
    }
}
