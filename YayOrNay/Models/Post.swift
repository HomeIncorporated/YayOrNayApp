//
//  Post.swift
//  YayOrNay
//
//  Created by Ilay on 03/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit

struct Post: Decodable {

    let creatorId: String
    let postId: String
    let occasionTag: Int
    let postTitle: String
    let postImage: String?
    var postUpvotes: Int
    var postDownvotes: Int
    var postBody: String?
    
    init(_ cId: String, _ pId: String, _ tag: Int, _ title: String, _ imageUrl: String, _ upvotes: Int, _ downvotes: Int, _ body: String) {
        self.creatorId = cId
        self.postId = pId
        self.postTitle = title
        self.occasionTag = tag
        self.postImage = imageUrl
        self.postUpvotes = upvotes
        self.postDownvotes = downvotes
        self.postBody = body
    }
}

