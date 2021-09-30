//
//  ViewController.swift
//  WorldTweets
//
//  Created by David Avendaño on 05/09/21.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication
            .shared
            .sendAction(#selector(UIApplication.resignFirstResponder),
                        to: nil, from: nil, for: nil)
        // Do any additional setup after loading the view.
        UserDefaults.standard.removeObject(forKey: "email")
    }
    
    
}

