//
//  WelcomeViewController.swift
//  WorldTweets
//
//  Created by David Avendaño on 07/09/21.
//

import UIKit

class WelcomeViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet weak var signInButton: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        signInButton.layer.cornerRadius = 25
    }

}
