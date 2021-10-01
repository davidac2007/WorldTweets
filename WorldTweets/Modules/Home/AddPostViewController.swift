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
import AVFoundation
import AVKit
import MobileCoreServices

class AddPostViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var watchVideoButton: UIButton!
    @IBOutlet weak var previewImage: UIImageView!
    
    //MARK: - IBActions
    
     var isPicture: Bool!
    
    @IBAction func addPostAction(){
        // uploadPicture()
        // openVideoCamera()
        uploadMedia(isCamera: isPicture)
    }
    
    @IBAction func dismissAction(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openCameraAction() {
        
        let alert = UIAlertController(title: "Source",
                                      message: "Select your media type",
                                      preferredStyle: UIAlertController.Style.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
       
            self.openCamera()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { _ in
           
            self.openVideoCamera()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func openPreviewAction() {
        guard let currentVideoURL = currentVideoUrl else{
            return
        }

        let avPlayer = AVPlayer(url: currentVideoURL)
        let avPLayerController = AVPlayerViewController()
        
        avPLayerController.player = avPlayer
        
        present(avPLayerController, animated: true) {
            avPLayerController.player?.play()
        }
    }
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    private var currentVideoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        watchVideoButton.isHidden = true
    }
    
    private func openVideoCamera(){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.mediaTypes = [kUTTypeMovie as String]
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .video
        imagePicker?.videoQuality = .typeMedium
        imagePicker?.videoMaximumDuration = TimeInterval(8)
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else { return }
        present(imagePicker, animated: true, completion: nil)
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
    
    // Make this two functions a single one
    
    private func uploadMedia(isCamera: Bool){
        
        
        print("Executing method, is camera \(isCamera) & is picture \(isPicture ?? true)")
        
        guard let imageSaved = previewImage.image,
              // Compress image
              let imageSavedData: Data = imageSaved.jpegData(compressionQuality: 0.1) else {
                  
                  return
              }
        
        guard let currentVideoSavedUrl = currentVideoUrl,
              let videoData: Data = try? Data(contentsOf: currentVideoSavedUrl) else {
                  
                  return
              }

        SVProgressHUD.show()
        
        // Config to save picture
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = self.isPicture ? "image/jpg" : "video/MP4"
        
        // Reference to storage
        let storage = Storage.storage()
        
        // Name the image
        let fileName = Int.random(in: 100...1000)
        
        let bucketRef = storage.reference(withPath: self.isPicture ? "tweets-photos/\(fileName).jpg" : "tweets-videos/\(fileName).mp4")
        
        print("Before: \(self.isPicture ?? true)")
        
        DispatchQueue.global(qos: .background).async{
            bucketRef.putData(self.isPicture ? imageSavedData : videoData, metadata: metaDataConfig) { (metadata: StorageMetadata?, error: Error?) in
                
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
                        self.savePost(imageUrl: self.isPicture ? downloadUrl : nil, videoUrl: self.isPicture ? nil : downloadUrl)
                    }
                }
            }
        }
    }
    
    private func savePost(imageUrl: String?, videoUrl: String?){
        
        
        let request = PostTweetsRequest(text: postTextView.text,
                                        imageUrl: imageUrl,
                                        videoUrl: videoUrl,
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
        
        // Get the image
        if info.keys.contains(.originalImage){
            self.isPicture = true
            previewImage.isHidden = false
            
            // Get the image from image picker
            previewImage.image = info[.originalImage] as? UIImage
        }
        
        if info.keys.contains(.mediaURL), let recordedVideoUrl = (info[.mediaURL] as? URL)?.absoluteURL {
            self.isPicture = false
            watchVideoButton.isHidden = false
            currentVideoUrl = recordedVideoUrl
            
        }
    }
}
