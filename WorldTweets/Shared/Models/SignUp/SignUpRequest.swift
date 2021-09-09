//
//  SignUpRequest.swift
//  WorldTweets
//
//  Created by David Avendaño on 08/09/21.
//

import Foundation

struct SignUpRequest: Codable{
    let email: String
    let password: String
    let names: String
}
