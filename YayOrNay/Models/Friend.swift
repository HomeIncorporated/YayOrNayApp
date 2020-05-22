//
//  Friend.swift
//  YayOrNay
//
//  Created by Ilay on 09/10/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import Foundation

struct Friend {
    let id: String
    let profilePicture: String
    let username: String
    let email: String
    
    
    static func addFriendToList(_ id: String, completion: @escaping(Bool)->()){
        
        var friend: Friend!

//        DispatchQueue.global(qos: .userInitiated).async {
//            let group = DispatchGroup()
//            group.enter()
//            // Getting user's deatils and creating a Friend object.
//            FirestoreService.shared.getUserDetailsById(user: id) { (newFriend) in
//                if newFriend != nil {
//                    friend = newFriend!
//                }
//                group.leave()
//            }
//            group.wait()
//            
//            // Adding the new Friend Object to the friends list of the current user
//            FirestoreService.shared.addUserToFriendsList(friend: friend) { (friendAdded) in
//                if friendAdded {
//                    FirestoreService.shared.fetchFriendList { (fetched) in
//                        if fetched {
//                            completion(true)
//                        }
//                    }
//                }
//            }
//        }
    }
    
    static func removeFriendFromList(_ id: String, completion: @escaping(Bool)->()){
        
        FirestoreService.shared.removeUserFromFriendsList(friendToRemove: id) { (removed) in
            if removed {
                FirestoreService.shared.fetchFriendList { (fetched) in
                    if fetched {
                        completion(true)
                    }
                }
            }else {
                print("FAILED TO REMOVE USER")
                //TODO: Show error to the user.
            }
        }
    }
}
