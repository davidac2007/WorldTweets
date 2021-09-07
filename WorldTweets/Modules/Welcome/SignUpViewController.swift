//
//  SignUpViewController.swift
//  WorldTweets
//
//  Created by David Avendaño on 07/09/21.
//

import UIKit

class SignUpViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI(){
        
        signUpButton.layer.cornerRadius = 25

    }
    
}
    
