//
//  PostDetail.swift
//  YayOrNay
//
//  Created by Ilay on 07/09/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit

class PostDetail: NSObject {
    
    let dimView = UIView()
    let detailView = DetailsView()
    var currentPost: Post? = nil
    
    
    override init() {
        super.init()
        
        let panGesture = PanDirectionGestureRecognizer(direction: .vertical(.down), target: self, action: #selector(panGestureRecognizerHandler(_:)))
        
        detailView.dismissIndicator.addGestureRecognizer(panGesture)
        detailView.delegate = self
        
    }
    
    convenience init(p: Post){
        self.init()
        currentPost = p
        
        FirestoreService.shared.isAlreadyAFriend(p.creatorId) { (isAFriend) in
            if isAFriend { self.detailView.isFriend = true }
            else { self.detailView.isFriend = false }
        }
        
        setPostDetails(post: p)
    }
    
    func showDetailView(){
        if let window = UIApplication.shared.keyWindow {
            dimView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            dimView.frame = window.frame
            
            window.addSubview(dimView)
            window.addSubview(detailView)
            
            let height = window.frame.height - 80
            let y = window.frame.height - height // This is so we can later slide detailView all the way down.
            
            detailView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            dimView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.dimView.alpha = 1
                self.detailView.frame = CGRect(x: 0, y: y, width: self.detailView.frame.width, height: self.detailView.frame.height)
            })
        }
    }
    
    @objc func handleDismiss(){
        UIView.animate(withDuration: 0.5) {
            self.dimView.alpha = 0
            if let window = UIApplication.shared.keyWindow  {
                self.detailView.frame = CGRect(x: 0, y: window.frame.height, width: self.detailView.frame.width, height: self.detailView.frame.height)
            }
        }
    }
    
    private func setPostDetails(post: Post) {
        guard let imageURL = post.postImage else { return }
        detailView.postTitle.text = post.postTitle
        detailView.upvotesLabel.text  = String(post.postUpvotes)
        detailView.downvotesLabel.text = String(post.postDownvotes)
        detailView.postImage.loadImageUsingCacheWithUrlString(urlString: imageURL)
        detailView.postBodyTextView.text = post.postBody
        
        guard let currentUserId = UserDefaults.standard.string(forKey: USER_UID_KEY) else { return } // getting the current user id from the userdefaults
        
        if post.creatorId == currentUserId { detailView.followBtn.isHidden = true // If we view our own post, we don't want the follow/unfollow button to appear.
        }
        
        switch post.occasionTag {
        case 0:
            self.detailView.postOccasion.text = CASUAL
        case 1:
            self.detailView.postOccasion.text = BEACH
        case 2:
            self.detailView.postOccasion.text = EVENING
        case 3:
            self.detailView.postOccasion.text = PARTY
        case 4:
            self.detailView.postOccasion.text = DATE
        case 5:
            self.detailView.postOccasion.text = WEDDING
        case 6:
            self.detailView.postOccasion.text = WORK
        default:
            self.detailView.postOccasion.text = CASUAL
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let id = post.creatorId
            FirestoreService.shared.getUserDetailsById(user: id) { (user) in
                if let user = user {
                    self.detailView.userProfileName.text = user.username
                    if user.image == "" {
                        self.detailView.profileImg.image = UIImage(named: "profileplaceholder")
                    }else {
                        self.detailView.profileImg.loadImageUsingCacheWithUrlString(urlString: user.image!) // force unwrapping here because we already checked this is not nil. we won't get to this block of code if it is nil.
                    }
                }
            }
        }
    }
    
}

extension PostDetail {
    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: detailView.dismissIndicator.window)
        var initialTouchPoint = CGPoint.zero
        
        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            if touchPoint.y > initialTouchPoint.y {
                detailView.frame.origin.y = initialTouchPoint.y + touchPoint.y
            }
        case .ended, .cancelled:
            if touchPoint.y - initialTouchPoint.y > 300 {
                handleDismiss()
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    
                    if let window = UIApplication.shared.keyWindow {
                        let height = window.frame.height - 80
                        let y = window.frame.height - height
                        
                        self.dimView.alpha = 1
                        self.detailView.frame = CGRect(x: 0, y: y, width: self.detailView.frame.width, height: self.detailView.frame.height)
                    }
                })
            }
        case .failed, .possible:
            break
        default:
            break
        }
    }
}

//MARK: Details Delegate
extension PostDetail: detailsDelegate {
    func handleFollow() {
        guard let friendId = self.currentPost?.creatorId else { return }
        if self.detailView.isFriend {
            Friend.removeFriendFromList(friendId) { (removed) in
                if removed {
                    self.detailView.isFriend = !self.detailView.isFriend
                }
            }
        }else {
            Friend.addFriendToList(friendId) { (added) in
                if added {
                    self.detailView.isFriend = !self.detailView.isFriend
                }
            }
        }
    }
}
