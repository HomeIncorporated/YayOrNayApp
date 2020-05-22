//
//  PostsVC.swift
//  YayOrNay
//
//  Created by Ilay on 12/09/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit
import FirebaseAuth
import Lottie

class PostsVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Properites
    private let reuseIdentifier = "PostCell"
    
    private let friendsLanuncher = ShowFriends()
    private var detailsLauncher = PostDetail()
    
    private var posts = [Post]()
    
    private let postsView = PostsView()
    
    var detailImage: UIImage? = nil //This property is used to send the image to the detail page
    
    override func loadView() {
        super.loadView()
        self.view = postsView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    fileprivate func setupView() {
        postsView.postsCollection.register(PostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        postsView.postsCollection.delegate = self
        postsView.postsCollection.dataSource = self
        postsView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        startLoadingAnimation()
        NotificationCenter.default.addObserver(self, selector: #selector(showPostsByUser(_:)), name: NSNotification.Name(rawValue: "postsByUserChosen"), object: nil)
        
        DispatchQueue.main.async {
            FirestoreService.shared.getPosts { (fetchedPosts) in
                self.posts = fetchedPosts
                self.stopLoadingAnimation()
                
                self.postsView.postsCollection.reloadData()
            }            
        }
    }
}

//MARK: UICollectionView functions
extension PostsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        
        cell.postTitle.text = post.postTitle
        cell.upvoteScoreLabel.text = String(post.postUpvotes)
        cell.downvoteScoreLabel.text = String(post.postDownvotes)
        
        if let postImageUrl = post.postImage {
            cell.cellImage.loadImageUsingCacheWithUrlString(urlString: postImageUrl)
        }
        
        //cell.upvotePostBtn.addTapGestureRecognizer { self.handleUpvote(indexPath.row) }
        //cell.downvotePostBtn.addTapGestureRecognizer { self.handleDownvote(indexPath.row) }
        
        cell.upvotePostBtn.addTapGestureRecognizer { self.handleVote(indexPath.row, VoteMode.upvote) }
        cell.downvotePostBtn.addTapGestureRecognizer { self.handleVote(indexPath.row, VoteMode.downvote) }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width * 0.95, height: 250)
        //Setting the height of PostCell to be 250, and the width of it to be 95% of the screen width.
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.handleImageTap(indexPath.row) // Sending to the function the specific image that the user tapped.
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
}

//MARK: Cell handlers
extension PostsVC {
    
    //    private func handleDelete(_ index: Int) {
    //        let postId = posts[index].postId
    //        let ac = UIAlertController(title: NSLocalizedString("sure", comment: "sure"), message: NSLocalizedString("delete.post.msg", comment: "delete msg"), preferredStyle: .alert)
    //        ac.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: "yes"), style: .destructive, handler: { (action) in
    //            FirestoreService.shared.deletePost(id: postId, completion: { (deleted) in
    //                if deleted {
    //                    self.posts.remove(at: index)
    //                    self.postsView.postsCollection.reloadData()
    //                }else {
    //                    let ac = UIAlertController(title: NSLocalizedString("error", comment: "error"), message: "delete.post.error.msg", preferredStyle: .alert)
    //                    ac.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .default, handler: nil))
    //                    self.present(ac, animated: true)
    //                }
    //            })
    //        }))
    //        ac.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil))
    //        self.present(ac, animated: true)
    //    }
    
    private func handleImageTap(_ index: Int) {
        let post = posts[index]
        detailsLauncher = PostDetail(p: post)
        detailsLauncher.showDetailView()
    }
    
    // index - using this to get the postId from the posts array
    // mode - using this to indicate if the user is trying to upvote or downvote the post
    private func handleVote(_ index: Int, _ mode: VoteMode){
        let postId = posts[index].postId
        FirestoreService.shared.voteForPost(post: postId, mode: mode) { (voted) in
            print(mode)
            if voted {
                print("POST VOTED.. \(mode)")
            }
        }
    }
    
    //    private func handleUpvote(_ index: Int) {
    //        let postId = posts[index].postId
    //        FirestoreService.shared.checkVoteForPost(post: postId) { (votemode) in
    //            print("THIS IS NOT NEEDED")
    //        }
    //        User.handleUpvote(post: postId) { (alreadyUpvoted, alreadyDownvoted) in
    //
    //            if alreadyUpvoted {
    //                self.posts[index].postUpvotes -= 1
    //            }else {
    //                self.posts[index].postUpvotes += 1
    //            }
    //            if alreadyDownvoted {
    //                self.posts[index].postDownvotes -= 1
    //            }
    //
    //            self.postsView.postsCollection.reloadData()
    //        }
}

private func handleDownvote(_ index: Int) {
    //        let postId = posts[index].postId
    //        User.handleDownvote(post: postId) { (alreadyDownvoted, removedUpvoted) in
    //
    //            if alreadyDownvoted {
    //                self.posts[index].postDownvotes -= 1
    //            }else{
    //                self.posts[index].postDownvotes += 1
    //            }
    //            if removedUpvoted {
    //                self.posts[index].postUpvotes -= 1
    //            }
    //
    //            self.postsView.postsCollection.reloadData()
    //        }
}


//MARK: PostsView Delegate
extension PostsVC: postsDelegate {
    
    func handleFriends() {
        friendsLanuncher.showFriends()
    }
    
    func handleLogout() {
        let ac = UIAlertController(title: NSLocalizedString("sure", comment: "Sure?"), message: NSLocalizedString("logout.msg", comment: "logout"), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: "yes"), style: .destructive, handler: { (action) in
            do {
                try! Auth.auth().signOut()
                UserDefaults.standard.removeObject(forKey: USER_UID_KEY)
                let vc = LoginVC()
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.show(vc, sender: self)
            }
        }))
        ac.addAction(UIAlertAction(title: NSLocalizedString("no", comment: "no"), style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    func handleAddPost() {
        let vc = NewpostVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleRefresh() {
        self.postsView.refreshButton.isHidden = true
        self.postsView.feedLabel.text = NSLocalizedString("feed.vc", comment: "feed")
        FirestoreService.shared.getPosts { (fetchedPosts) in
            self.posts = fetchedPosts
            self.postsView.postsCollection.reloadData()
        }
    }
}

//MARK: Helper functions
extension PostsVC {
    func startLoadingAnimation() {
        self.postsView.loadingAnimation.isHidden = false
        self.postsView.loadingAnimation.play()
    }
    
    func stopLoadingAnimation() {
        self.postsView.loadingAnimation.stop()
        self.postsView.loadingAnimation.isHidden = true
        
    }
    
    @objc func showPostsByUser(_ notification: NSNotification) {
        self.postsView.refreshButton.isHidden = false
        let userName = try? notification.userInfo?["byUser"] as! String
        
        let newScreenTitle = NSLocalizedString("posts.by", comment: "posts by") + " \(userName ?? "Not found")"
        
        self.postsView.feedLabel.text = newScreenTitle
        self.posts = POSTS_BY_USER
        self.postsView.postsCollection.reloadData()
    }
}
