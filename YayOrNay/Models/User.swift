//
//  User.swift
//  YayOrNay
//
//  Created by Ilay on 04/09/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit

struct User: Decodable {
    
    let id: String
    let email: String
    let username: String
    let image: String?
    let following: [String]?
    let votes: [String: Int]?
    
    init(_ id: String, _ email: String, _ name: String, _ image: String?, _ following: [String]?, _ votes: [String: Int]?) {
        self.id = id
        self.email = email
        self.username = name
        self.image = image
        self.following = following
        self.votes = votes
    }
}
