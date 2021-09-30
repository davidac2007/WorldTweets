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
import FirebaseStorage

class AddPostViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var previewImage: UIImageView!
    
    //MARK: - IBActions
   
    @IBAction func addPostAction(){
        uploadPicture()
    }
    
    @IBAction func dismissAction(){
        dismiss(animated: true, completion: nil)
    }
    @IBAction func openCameraAction() {
        openCamera()
    }
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        // Do any additional setup after loading the view.
    }
    
    private func openCamera(){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .photo
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        
        present(imagePicker, animated: true, completion: nil)

    }
    
    private func uploadPicture(){
        // Make sure the picture exists
        guard let imageSaved = previewImage.image,
              // Compress image
              let imageSavedData: Data = imageSaved.jpegData(compressionQuality: 0.1) else {
                return
              }
        
        SVProgressHUD.show()
        
        // Config to save picture
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        
        // Reference to storage
        let storage = Storage.storage()
        
        // Name the image
        let imageName = Int.random(in: 100...1000)
        
        // Reference to bucket in Storage
        let bucketRef = storage.reference(withPath: "tweets-photos/\(imageName).jpg")
        
        // Upload picture to Firebase Storage
        DispatchQueue.global(qos: .background).async{
            bucketRef.putData(imageSavedData, metadata: metaDataConfig) { (metadata: StorageMetadata?, error: Error?) in
                    
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    
                    if let error = error{
                        NotificationBanner(title: "Error",
                                           subtitle: error.localizedDescription,
                                        style: .warning).show()
                        return
                    }
                    bucketRef.downloadURL { (url: URL?,error: Error?) in
                        let downloadUrl = url?.absoluteString ?? ""
                        self.savePost(imageUrl: downloadUrl)
                    }
                }
            }
        }
        
    }
    
    private func savePost(imageUrl: String){
        
        
        let request = PostTweetsRequest(text: postTextView.text,
                                        imageUrl: imageUrl,
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

// MARK: - Extensions
extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Close image picker
        
        imagePicker?.dismiss(animated: true, completion: nil)
        
        if info.keys.contains(.originalImage){
            previewImage.isHidden = false
            
            // Get the image from image picker
            previewImage.image = info[.originalImage] as? UIImage
        }
    }
}
