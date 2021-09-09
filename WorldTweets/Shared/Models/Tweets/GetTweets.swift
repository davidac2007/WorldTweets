//
//  GetTweets.swift
//  WorldTweets
//
//  Created by David Avendaño on 08/09/21.
//

import Foundation

struct GetTweets: Codable{
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

struct Author: Codable{
    let email: String
    let names: String
    let nickname: String
}

struct Location: Codable{
    let latitude: Double
    let longitude: Double
}

