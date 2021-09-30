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
    
    @IBAction func addPostAction(){
        // uploadPicture()
        // openVideoCamera()
        uploadVideo()
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
        // Do any additional setup after loading the view.
    }
    
    private func openVideoCamera(){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.mediaTypes = [kUTTypeMovie as String]
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .video
        imagePicker?.videoQuality = .typeMedium
        imagePicker?.videoMaximumDuration = TimeInterval(5)
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        
        guard let imagePicker = imagePicker else {
            return
        }
        
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
                        self.savePost(imageUrl: downloadUrl, videoUrl: nil)
                    }
                }
            }
        }
        
    }
    
    private func uploadVideo(){
        // Make sure the video exists
        guard let currentVideoSavedUrl = currentVideoUrl,
              let videoData: Data = try? Data(contentsOf: currentVideoSavedUrl) else {
                  return
              }
        
        SVProgressHUD.show()
        
        // Config to save picture
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "video/MP4"
        
        // Reference to storage
        let storage = Storage.storage()
        
        // Name the video
        let videoName = Int.random(in: 100...1000)
        
        // Reference to bucket in Storage
        let bucketRef = storage.reference(withPath: "tweets-videos/\(videoName).mp4")
        
        // Upload video to Firebase Storage
        DispatchQueue.global(qos: .background).async{
            bucketRef.putData(videoData, metadata: metaDataConfig) { (metadata: StorageMetadata?, error: Error?) in
                
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
                        self.savePost(imageUrl: nil, videoUrl: downloadUrl)
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
            previewImage.isHidden = false
            
            // Get the image from image picker
            previewImage.image = info[.originalImage] as? UIImage
        }
        
        if info.keys.contains(.mediaURL), let recordedVideoUrl = (info[.mediaURL] as? URL)?.absoluteURL {
            watchVideoButton.isHidden = false
            currentVideoUrl = recordedVideoUrl
        }
    }
}
