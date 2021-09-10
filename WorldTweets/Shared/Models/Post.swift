//
//  GetTweets.swift
//  WorldTweets
//
//  Created by David Avendaño on 08/09/21.
//

import Foundation

struct Post: Codable{
    let id: String
    let author: User
    let imageUrl: String
    let text: String
    let videoUrl: String
    let location: PostLocation
    let hasVideo: Bool
    let hasImage: Bool
    let hasLocation: Bool
    let createdAt: String
}

