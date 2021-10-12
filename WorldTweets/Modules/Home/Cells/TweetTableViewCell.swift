//
//  TweetTableViewCell.swift
//  WorldTweets
//
//  Created by David Avendaño on 14/09/21.
//

import UIKit
import Kingfisher

class TweetTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
//    Important
    // Cells should never invoke view controllers
    
    @IBAction func openVideo() {
        guard let videoUrl = videoUrl else {return}
        needsToShowVideo?(videoUrl)
    }
    
    // MARK: - Properties
    
    private var videoUrl: URL?
    var needsToShowVideo: ((_ url: URL) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellWith(post: Post){
        nameLabel.text = post.author.names
        nicknameLabel.text = post.author.nickname
        messageLabel.text = post.text
        videoButton.isHidden = post.videoUrl.isEmpty
        
        if post.hasImage{
            // Setup image
            tweetImageView.kf.setImage(with: URL(string: post.imageUrl))
        } else{
            tweetImageView.isHidden =  false
        }
        
        videoUrl = URL(string: post.videoUrl)
    }
    
}
