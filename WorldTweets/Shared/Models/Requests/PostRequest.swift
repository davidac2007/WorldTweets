//
//  PostViews.swift
//  WorldTweets
//
//  Created by David Avendaño on 08/09/21.
//

import Foundation

struct PostTweetsRequest: Codable{
    let text: String
    let imageUrl: String?
    let videoUrl: String?
    let location: PostLocation?
}
