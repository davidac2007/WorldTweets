//
//  AddPostViewController.swift
//  WorldTweets
//
//  Created by David Avendaño on 16/09/21.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift

class AddPostViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet weak var postTextView: UITextView!
    
    
    //MARK: - IBActions
   
    @IBAction func addPostAction(){
        savePost()
    }
    
    @IBAction func dismissAction(){
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.layer.cornerRadius = 20.0
        // Do any additional setup after loading the view.
    }
    
    private func savePost(){
        
        let request = PostTweetsRequest(text: postTextView.text,
                                        imageUrl: nil,
                                        videoUrl: nil,
                                        location: nil)
        
        SVProgressHUD.show()
        
        SN.post(endpoint: Endpoints.post, model: request) { (response: SNResultWithEntity<Post, ErrorResponse>) in
            
            SVProgressHUD.dismiss()
            
            switch response {
                // Success login
                case .success:
                    self.dismiss(animated: true, completion: nil)
                    
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
        }
        
    }
}
