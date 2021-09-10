//
//  LoginResponse.swift
//  WorldTweets
//
//  Created by David Avendaño on 08/09/21.
//

import Foundation

struct LoginResponse: Codable{
    let user: User
    let token: String
}
