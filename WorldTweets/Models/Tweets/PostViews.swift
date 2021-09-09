//
//  PostViews.swift
//  WorldTweets
//
//  Created by David Avendaño on 08/09/21.
//

import Foundation

struct PostTweetsRequest{
    let text: String
    let imageUrl: String
    let videoUrl: String
    let location: Location
}

struct PostTweetsResponse{
    let id: String
    let author: Author
    let imageUrl: String
    let text: String
    let videoUrl: String
    let location: Location
    let hasVideo: Bool
    let hasImage: Bool
    let hasLocation: Bool
    let createdAt: String
}
