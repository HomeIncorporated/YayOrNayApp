//
//  RestManager.swift
//  YayOrNay
//
//  Created by Ilay on 03/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

private let db = Firestore.firestore()

class FirestoreService: NSObject {
    
    static let shared = FirestoreService()
    private let storage = Storage.storage()
    private let uuid = UserDefaults.standard.string(forKey: USER_UID_KEY) ?? ""

    //MARK: SIGNUP
    func signupUser(_ email: String, _ pass: String, _ username: String, completion:
        @escaping(Bool, Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: pass) { (user, error) in
            if user != nil && error == nil {
                completion(true, nil)
            }else {
                completion(false, error)
            }
        }
    }
    
    //MARK: LOGIN
    func loginUser(_ email: String, _ pass: String, completion: @escaping (Bool, Error?) -> ()){
        Auth.auth().signIn(withEmail: email, password: pass) { (user, err) in
            if err == nil && user != nil  {
                completion(true, nil)
            }else {
                completion(false, err!)
            }
        }
        completion(false, nil)
    }
    
    //MARK: GET POSTS
    func getPosts(completion: @escaping ([Post]) -> ()){
        var fetchedPosts = [Post]()
        let collectionRef = db.collection(POSTS_COLLECTION)
        
        var body = ""

        collectionRef.getDocuments { (snapshot, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            //Getting all documents from collection
            guard let data = snapshot?.documents else { return }
            
            //Iterating on each document, and creating a post object from it
            for document in data {
                
                //Getting every detail we need from the document
                guard let cid = document.get(POST_CREATOR) as? String else { return }
                guard let pid = document.get(POST_ID) as? String else { return }
                guard let tag = document.get(POST_OCCASION_TAG) as? Int else { return }
                guard let title = document.get(POST_TITLE) as? String else { return }
                guard let image = document.get(POST_IMAGE) as? String else { return }
                guard let upvotes = document.get(POST_UPVOTES) as? Int else { return }
                guard let downvotes = document.get(POST_DOWNVOTES) as? Int else { return }
                if let b = document.get(POST_BODY) as? String { body = b }
                //
                
                //creating a new post with the info we got
                let p = Post(cid, pid, tag, title, image, upvotes, downvotes, body)
                
                //adding the new post to the posts array so we can use it later (show posts, etc)
                fetchedPosts.append(p)
            }
            completion(fetchedPosts)
        }
    }
    
    //MARK: Delete post
    func deletePost(id postId: String, completion: @escaping(Bool)->()){
        db.collection(POSTS_COLLECTION).document(postId).delete { (error) in
            if let err = error {
                print(err.localizedDescription)
                completion(false)
            }else {
                completion(true)
            }
        }
    }
    
    //MARK: uploadImageToFirebase
    // Uploading the image (profile, post) to the firebase storage
    func uploadImageToFirebase(_ imageToUpload: UIImage? , completion: @escaping((_ url: String?)->())){
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference()
        let imagesRef = storageRef.child(imageName)
        guard let uploadData = imageToUpload?.jpegData(compressionQuality: 0.8) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imagesRef.putData(uploadData, metadata: metaData) { (metadata, err) in
            
            if err == nil && metadata != nil {
                imagesRef.downloadURL(completion: { (url, err) in
                    guard let downloadUrl = url else { return } // TODO: Tell users there is a problem instead of just return
                    let urlString = downloadUrl.absoluteString
                    completion(urlString)
                })
            }else {
                print(err?.localizedDescription)
            }
            completion(nil)
        }
    }
    
    //MARK: addNewUserToDatabase
    func addNewUserToDatabase(_ user: User, completion: @escaping(Bool) ->()){
        db.collection(USERS_COLLECTION).document(user.id).setData([
            USER_ID: user.id,
            USER_NAME: user.username,
            USER_MAIL: user.email,
            USER_PROFILE_IMAGE: user.image,
            USER_FOLLOWING: user.following,
            USER_VOTES: user.votes,
        ]) { (error) in
            if let _ = error {
                completion(false)
            }else {
                completion(true)
            }
        }
    }
    
    //MARK: voteForPost
    //mode VoteMode will say if the user wants to upvote or downvote the post.
    func voteForPost(post id: String, mode: VoteMode, completion: @escaping(Bool)->()) {
        checkVoteForPost(post: id) { (voted) in
            if voted == VoteMode.novote {
                switch mode {
                case .upvote:
                    self.upvotePost(post: id) { (upvoted) in
                        if upvoted {
                            completion(true)
                        }
                    }
                case .downvote:
                    self.downvotePost(post: id) { (downvoted) in
                        if downvoted {
                            completion(true)
                        }
                    }
                default:
                    completion(false)
                }
            }
                //if already upvoted/downvoted and trying to upvote/downvote again, remove the vote.
            else if voted == mode{
                switch mode{
                case .upvote:
                    self.removeUpvote(post: id) { (removed) in
                        if removed {
                            print("REMOVED UPVOTE.")
                        }
                    }
                case .downvote:
                    self.removeDownvote(post: id) { (removed) in
                        if removed {
                            print("REMOVED DOWNVOTE.")
                        }
                    }
                default:
                    return
                }
            }
                // if already voted the opposite, we should change the vote, for example, voted upvote, and now trying to downvote.
            else {
                self.changeVote(post: id, change: voted, to: mode) { (changed) in
                    if changed {
                        print("CHANGED VOTE")
                    }
                }
            }
        }
    }
    
    //MARK: changeVote
    func changeVote(post id: String, change fromVote: VoteMode, to vote: VoteMode, completion: @escaping(Bool)->()){
        removeVote(post: id, voteType: fromVote) { (removed) in
            if removed {
                self.voteForPost(post: id, mode: vote) { (voted) in
                    if voted {
                        completion(true)
                    }
                }
            }
            completion(false)
        }
    }
    
    //MARK: removeVote
    //In here, we need to remove the post id from the user's list, and remove the score from the post document itself.
    func removeVote(post id: String, voteType mode: VoteMode, completion: @escaping(Bool)->()) {
        switch mode {
        case .upvote:
            removeUpvote(post: id) { (removed) in
                completion(removed) // true or false, removed the vote or not.
            }
        case .downvote:
            removeDownvote(post: id) { (removed) in
                completion(removed) // true or false, removed the vote or not.
            }
        default:
            debugPrint("RETURNED FROM REMOVEVOTE")
            return
        }
    }
    
    //MARK: removeUpvote
    func removeUpvote(post id: String, completion: @escaping(Bool)->()) {
        let postRef = db.collection(POSTS_COLLECTION).document(id)
        let userRef = db.collection(USERS_COLLECTION).document(self.uuid)
        
        var s = 0 // the posts score
        var currentDict = [String: Any]() // the user's votes dictionary
        
        //Getting the current post score and subtracting one from it.
        postRef.getDocument { (doc, error) in
            if let _ = error {
                completion(false)
            }
            
            guard let score = doc?.get(POST_UPVOTES) as? Int else { return }
            s = score
            s -= 1
        }
        
        //Updating the upvotes score to the new score.
        postRef.updateData([
            POST_UPVOTES: s,
        ]) { (error) in
            if let _ = error {
                completion(false)
            }
        }
        
        //getting the user's votes dictionary and removing the post from it.
        userRef.getDocument { (doc, error) in
            if let _ = error { completion(false) }
            guard let dict = doc?.data()?[USER_VOTES] as? [String: Any] else { return }
            currentDict = dict
            currentDict.removeValue(forKey: id)
        }
        
        //setting the votes dictionary with the updated one.
        userRef.setData(currentDict) { (error) in
            if let _ = error { completion(false) }
            else { completion(true) }
        }
    }
    
    //MARK: removeDownvote
    func removeDownvote(post id: String, completion: @escaping(Bool)->()){
    
    }
    
    //MARK: upvotePost
    func upvotePost(post id: String, completion: @escaping(Bool)->()){
        //Getting the document of the post, by it's id.
        db.collection(POSTS_COLLECTION).document(id).getDocument { (doc, error) in
            if let _ = error {
                completion(false)
            }
            
            let score = doc?.get(POST_UPVOTES) as? Int
            guard var s = score else { return }
            s = s + 1
            
            //Updating the score field in post
            db.collection(POSTS_COLLECTION).document(id).updateData([
                POST_UPVOTES: s,
            ]) { (error) in
                if let _ = error {
                    completion(false)
                }
                
                //If successfully updated the score, we should add the post id and 1 to the user that upvoted it.
                db.collection(USERS_COLLECTION).document(self.uuid).setData([
                    USER_VOTES: [id: UPVOTED_POST]
                ], merge: true) { (error) in
                    if let _ = error {
                        completion(false)
                    }
                    
                    completion(true)
                }
            }
        }
    }
    
    //MARK: downvotePost
    func downvotePost(post id: String, completion: @escaping(Bool)->()){
        //Getting the document of the post, by it's id.
        db.collection(POSTS_COLLECTION).document(id).getDocument { (doc, error) in
            if let _ = error {
                completion(false)
            }
            
            let score = doc?.get(POST_DOWNVOTES) as? Int
            guard var s = score else { return }
            s = s - 1
            
            //Updating the score field in post
            db.collection(POSTS_COLLECTION).document(id).updateData([
                POST_DOWNVOTES: s,
            ]) { (error) in
                if let _ = error {
                    completion(false)
                }
                
                //If successfully updated the score, we should add the post id and 1 to the user that upvoted it.
                db.collection(USERS_COLLECTION).document(self.uuid).setData([
                    USER_VOTES: [id: DOWNVOTED_POST]
                ], merge: true) { (error) in
                    if let _ = error {
                        completion(false)
                    }
                    
                    completion(true)
                }
            }
        }
    }
    
    //MARK: checkForUsernameExists
    // Checking if the username choosen already exist, so we don't have duplicates
    func checkForUsernameExists(_ username: String, completion: @escaping(Bool)->()) {
        db.collection(USERS_COLLECTION).whereField(USER_NAME, isEqualTo: username).getDocuments { (snapshot, err) in
            guard let numberOfDocuments = snapshot?.documents.count else { return }
            if numberOfDocuments == 0 {
                //If no documents were found, the username is available.
                completion(true)
            }else { completion(false) }
        }
    }
    
    //MARK: removeUserFromFriendsList
    // Getting an id, and removing it from the 'following' list inside the current uesr document
    func removeUserFromFriendsList(friendToRemove id: String, completion: @escaping(Bool)->()) {
        let friendsRef = db.collection(USERS_COLLECTION).document(self.uuid)
        friendsRef.updateData([
            USER_FOLLOWING + "." + id : FieldValue.delete()
        ]) { (error) in
            if error != nil {
                completion(false)
            }
            completion(true)
        }
    }
    
    //MARK: addUserToFriendsList
    // Getting a Friend object and adding it to the current user document.
    func addUserToFriendsList(friend newFriend: Friend, completion: @escaping(Bool)->()) {
        db.collection(USERS_COLLECTION).document(self.uuid).setData([
            USER_FOLLOWING : [
                newFriend.id: [
                    FRIEND_ID: newFriend.id,
                    FRIEND_MAIL: newFriend.email,
                    FRIEND_NAME: newFriend.username,
                    FRIEND_PROFILE_PIC: newFriend.profilePicture
                ]
            ]
        ], merge: true) { (err) in
            if err != nil {
                print(err?.localizedDescription)
                completion(false)
            }else {
                completion(true)
            }
        }
    }

    //MARK: getUserDetailsById
    func getUserDetailsById(user id: String, completion: @escaping(User?) ->()){
        db.collection(USERS_COLLECTION).document(id).getDocument { (doc, error) in
            if let _ = error {
                debugPrint(error?.localizedDescription)
                return
            }
            
            guard let user_id = doc?.documentID else { return }
            guard let user_mail = doc?.data()?[USER_MAIL] as? String else { return }
            guard let user_name = doc?.data()?[USER_NAME] as? String else { return }
            guard let user_profile_image = doc?.data()?[USER_PROFILE_IMAGE] as? String else { return }
            
            let user = User(user_id, user_mail, user_name, user_profile_image, nil, nil) //TODO: Fix this force unwrapping, this may cause crashes.
            completion(user)
            
        }
    }
    
    //MARK: fetchFriendList
    func fetchFriendList(completion: @escaping(Bool)->()) {
        guard let uid = UserDefaults.standard.string(forKey: USER_UID_KEY) else { return }
        
        var fetchedFriends: [Friend] = []
        db.collection(USERS_COLLECTION).document(uid).getDocument { (doc, err) in
            if err == nil { // If we didn't get an error.
                if let doc = doc { // Checking if we got a document
                    if let results = doc.data()?[USER_FOLLOWING] as? [String: Any] {
                        if results.isEmpty {
                            FRIENDS_LIST = []
                            completion(true) // we did fetched, but nothing was there so we are setting FRIENDS_LIST to and empty array and returning true, we DID NOT fail to fetch, we fetched nothing.
                        }else {
                            for result in results {
                                if let resultValue = result.value as? [String: Any] { // Getting only the value of the MAP data, we do not need the key.
                                    
                                    //Getting the fields from the result
                                    guard let id = resultValue[FRIEND_ID] as? String else { return }
                                    guard let profilePic = resultValue[FRIEND_PROFILE_PIC] as? String else { return }
                                    guard let username = resultValue[FRIEND_NAME] as? String else { return }
                                    guard let email = resultValue[FRIEND_MAIL] as? String else { return }
                                    
                                    //Creating a new Friend object from the fields
                                    let friend = Friend(id: id, profilePicture: profilePic, username: username, email: email)
                                    
                                    fetchedFriends.append(friend)
                                }
                            }
                            FRIENDS_LIST = fetchedFriends
                            completion(true)
                        }
                    }
                }
            }else { // Couldn't get the doc and got an error.
                print(err?.localizedDescription)
                completion(false)
            }
        }
    }
    
    //MARK: isAlreadyAFriend
    func isAlreadyAFriend(_ friendId: String, completion: @escaping(Bool)->()) {
        var fetchedFriends: [String] = []
        db.collection(USERS_COLLECTION).document(self.uuid).getDocument { (doc, err) in
            if err == nil && doc != nil {
                guard let results = doc?.data()?[USER_FOLLOWING] as? [String: Any] else { return }
                for result in results {
                    let userId = result.key
                    fetchedFriends.append(userId)
                }
                if fetchedFriends.contains(friendId) {
                    completion(true)
                }else {
                    completion(false)
                }
            }else {
                print(err!.localizedDescription)
                completion(false)
            }
        }
    }
    
    //MARK: searchForUser
    func searchForUser(user name: String, completion: @escaping(Friend?)->()) {
        var foundUser: Friend?
        
        db.collection(USERS_COLLECTION).whereField(USER_NAME, isEqualTo: name).getDocuments { (doc, err) in
            if err != nil {
                print(err?.localizedDescription)
                completion(nil)
            }else if let doc = doc {
                let userId = doc.documents[0].documentID
                let userDocument = doc.documents[0].data()
                
                guard let mail = userDocument[USER_MAIL] as? String else { return }
                guard let username = userDocument[USER_NAME] as? String else { return }
                guard let image = userDocument[USER_PROFILE_IMAGE] as? String else { return }
                
                let potentialFriend = Friend(id: userId, profilePicture: image, username: username, email: mail)
                foundUser = potentialFriend
            }else {
                completion(nil)
            }
            completion(foundUser)
        }
    }
    
    //MARK: fetchPostsByUser
    func fetchPostsByUser(user id: String, completion: @escaping([Post])->()) {
        var postsByUser: [Post] = []
        db.collection(POSTS_COLLECTION).whereField(POST_CREATOR, isEqualTo: id).getDocuments { (snapshot, err) in
            if err == nil {
                if let docs = snapshot { // checking if we got something in snapshot
                    for doc in docs.documents {
                        let id = try! doc[POST_CREATOR] as! String
                        let post_id = try! doc.documentID as String
                        let tag = try! doc[POST_OCCASION_TAG] as! Int
                        let title = try! doc[POST_TITLE] as! String
                        let image = try! doc[POST_IMAGE] as! String
                        let upvotes = try! doc[POST_UPVOTES] as! Int
                        let downvotes = try! doc[POST_DOWNVOTES] as! Int
                        let body = try! doc[POST_BODY] as! String
                        let p = Post(id, post_id, tag, title, image, upvotes, downvotes, body)
                        postsByUser.append(p)
                    }
                }
            }
            completion(postsByUser)
        }
    }
    
    //MARK: checkVoteForPost
    func checkVoteForPost(post id: String, completion: @escaping(VoteMode) ->()){
        let user_id = UserDefaults.standard.string(forKey: USER_UID_KEY)!
        let userRef = db.collection(USERS_COLLECTION).document(user_id)
        userRef.getDocument { (doc, error) in
            if let _ = error {
                return
            } else if doc != nil {
                guard let votes = doc?.data()?[USER_VOTES] as? [String: Any] else { return }
                
                for vote in votes {
                    if vote.key == id {
                        guard let voteString = vote.value as? String else { return }
                        guard let voteMode = voteString as? Int else { return }
                        switch voteMode {
                        case -1:
                            completion(VoteMode.downvote)
                        case  1:
                            completion(VoteMode.upvote)
                        default:
                            completion(VoteMode.novote)
                        }
                    }
                }
                completion(VoteMode.novote)
            }
        }
    }
}



