//
//  SignUpViewController.swift
//  WorldTweets
//
//  Created by David Avendaño on 07/09/21.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

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
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI(){
        
        signUpButton.layer.cornerRadius = 25
        emailTextField.autocorrectionType = .no
    }
    
    private func performSignUp(){
        
        func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
        }
        
        guard let name = nameTextField.text,
              !name.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Please enter your name",style: .warning).show()
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty && isValidEmail(email) else {
            NotificationBanner(title: "Error", subtitle: "Enter a valid email",style: .warning).show()
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else{
            NotificationBanner(title: "Error", subtitle: "Enter a valid password",style: .warning).show()
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, confirmPassword == password else{
            NotificationBanner(title: "Error", subtitle: "The passwords doesn't match",style: .warning).show()
            return
        }
        
        // Create request
        let request = SignUpRequest(email: email, password: password, names: name)
        
        let defaults = UserDefaults.standard
      
        SVProgressHUD.show()
        
        // Call service
        
        SN.post(endpoint: Endpoints.signUp, model: request) {(response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            
            SVProgressHUD.dismiss()
            
            switch response {
                // Success login
                case .success(let user):
                    NotificationBanner(subtitle: "Welcome \(user.user.names)",style: .success).show()
                
                    defaults.set(email, forKey: "email")
                    let currentEmail = defaults.string(forKey: "email")
                    print("This is the current email: \(currentEmail ?? "")")
                
                    // Perform login
                    self.performSegue(withIdentifier: "showHome", sender: nil)
                    SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)

                // Unknown errors
                case .error(let error):
                    NotificationBanner(title: "Error",
                                       subtitle: error.localizedDescription,
                                       style: .danger).show()
                   
                // Errrors from the server
                case .errorResult(let entity):
                    NotificationBanner(title: "Error",
                                    subtitle: entity.error,
                                    style: .warning).show()
                    
            }
        // Perform Sign Up
//        performSegue(withIdentifier: "showHome", sender: nil)
    
    }
   }
}
    
