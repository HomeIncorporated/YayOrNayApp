//
//  Constants.swift
//  YayOrNay
//
//  Created by Ilay on 10/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import Foundation

//Friends List
var FRIENDS_LIST: [Friend] = []
var POSTS_BY_USER: [Post] = [] //This will be used when the user clicks on a friend in the friends list, we will populate this array with the fechted posts we will get so we can display it on the main screen.

//User Defaults
let USER_UID_KEY = "user.uid.key"

//Firestore Collections
let USERS_COLLECTION = "users"
let POSTS_COLLECTION = "posts"
let COMMENTS_COLLECTION = "comments"

//Firestore Users
let USER_ID = "user_id"
let USER_MAIL = "useremail"
let USER_NAME = "username"
let USER_FOLLOWING = "following"
let USER_PROFILE_IMAGE = "profile_image"
let USER_VOTES = "votes"

//Firestore Friend Object
let FRIEND_NAME = "name"
let FRIEND_MAIL = "email"
let FRIEND_PROFILE_PIC = "profile_image"
let FRIEND_ID = "id"

//Firestore Posts
let POST_CREATOR = "postCreator"
let POST_ID = "postId"
let POST_OCCASION_TAG = "postTag"
let POST_TITLE = "postTitle"
let POST_IMAGE = "postImage"
let POST_UPVOTES = "postUpvotes"
let POST_DOWNVOTES = "postDownvotes"
let POST_BODY = "postBody"

//Outfit occasion
let CASUAL = "Casual"
let BEACH = "Beach"
let EVENING = "Evening"
let PARTY = "Party"
let DATE = "Date"
let WEDDING = "Wedding"
let WORK = "Work"

//Vote scores (indicating if the post was upvoted or downvoted)
let UPVOTED_POST = 1
let DOWNVOTED_POST = -1
