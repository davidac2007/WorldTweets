//
//  SignInViewController.swift
//  WorldTweets
//
//  Created by David Avendaño on 07/09/21.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

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
        
        // Create request
        let request = LoginRequest(email: email, password: password)
        
        // Start loading spinner
        SVProgressHUD.show()
        
        // Call Networking Library
        SN.post(endpoint: Endpoints.login, model: request) {(response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            
            switch response {
                case .success(let user):
                    NotificationBanner(subtitle: "Welcome \(user.user.names)",style: .success).show()
                    SVProgressHUD.dismiss()
                    // Perform login
                    self.performSegue(withIdentifier: "showHome", sender: nil)
                case .error(let error):
                    NotificationBanner(title: "Error",
                                       subtitle: error.localizedDescription,
                                       style: .danger).show()
                    SVProgressHUD.dismiss()
                case .errorResult(let entity):
                    NotificationBanner(title: "Error",
                                    subtitle: entity.error,
                                    style: .warning).show()
                    SVProgressHUD.dismiss()
            }
        }
    }
}
