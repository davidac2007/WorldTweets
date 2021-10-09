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
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    private var currentVideoUrl: URL?
    private var isCamera: Bool = true
    private var currentImageUrl: Data?
    
    //MARK: - IBActions
    
    @IBAction func addPostAction(){
        uploadMedia(isCameraSource: isCamera)
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
    
    private func uploadMedia(isCameraSource: Bool){

        // Make sure the media file exists
        guard let mediaData: Data =
                isCameraSource ?
                previewImage.image?.jpegData(compressionQuality: 0.1) :
                try? Data(contentsOf: currentVideoUrl!)
        else {
            return
        }
        
        SVProgressHUD.show()
        
        // Config to save media
        let metaDataConfig = StorageMetadata()
        
        // Specify content type
        metaDataConfig.contentType = isCameraSource ? "image/jpg" : "video/MP4"
        
        // Reference to storage
        let storage = Storage.storage()
        
        // Name the media file
        let fileName = Int.random(in: 100...1000)
        
        // Reference to bucket in Storage
        let bucketRef = storage.reference(withPath: isCameraSource ? "tweets-photos/\(fileName).jpg" : "tweets-videos/\(fileName).mp4")
        
        DispatchQueue.global(qos: .background).async {
            bucketRef.putData(mediaData, metadata: metaDataConfig) { (metadata: StorageMetadata?, error: Error?) in
              
                print("Is camera source: \(isCameraSource)")
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
                        self.savePost(imageUrl: isCameraSource ? downloadUrl : nil, videoUrl: isCameraSource ? nil : downloadUrl)
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
            self.isCamera = true
            previewImage.isHidden = false
            
            // Get the image from image picker
            previewImage.image = info[.originalImage] as? UIImage
            currentImageUrl = previewImage.image?.jpegData(compressionQuality: 0.1)
            
        }
        
        if info.keys.contains(.mediaURL), let recordedVideoUrl = (info[.mediaURL] as? URL)?.absoluteURL {
            watchVideoButton.isHidden = false
            currentVideoUrl = recordedVideoUrl
            self.isCamera = false
        }
    }
}
