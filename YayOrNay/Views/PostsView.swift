//
//  PostsView.swift
//  YayOrNay
//
//  Created by Ilay on 12/09/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit
import Lottie

protocol postsDelegate {
    
    func handleFriends()
    func handleLogout()
    func handleAddPost()
    func handleRefresh()
}

class PostsView: UIView {
    
    var delegate: postsDelegate?

    //MARK: Properties
    let logoutBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .clear
        btn.setTitle(NSLocalizedString("logout.btn", comment: "logout"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        btn.setTitleColor(UIColor.appWhiteAccent, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return btn
    }()
    
    let addPostBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "add"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleAddPost), for: .touchUpInside)
        
        return btn
    }()
    
    let refreshButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "refresh"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        btn.isHidden = true
        
        return btn
    }()
    
    
    let feedLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.isUserInteractionEnabled = false
        lbl.text = NSLocalizedString("feed.vc", comment: "Feed")
        lbl.textColor = UIColor.appWhite
        lbl.font = UIFont.boldSystemFont(ofSize: 36)
        lbl.adjustsFontSizeToFitWidth = true
        
        return lbl
    }()
    
    let friendsBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .clear
        btn.setTitle(NSLocalizedString("friends.btn", comment: "Friends"), for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.setTitleColor(UIColor.appWhiteAccent, for: .normal)
        btn.addTarget(self, action: #selector(handleFriends), for: .touchUpInside)
        return btn
    }()
    
    let postsCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let table = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    let loadingAnimation: AnimationView = {
        let view = AnimationView()
        let animation = Animation.named("loading")
        view.animation = animation
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    //MARK: UI Setting
    private func setupAddPostBtn(){
        addSubview(addPostBtn)
        NSLayoutConstraint.activate([
            addPostBtn.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            addPostBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            addPostBtn.widthAnchor.constraint(equalToConstant: 25),
            addPostBtn.heightAnchor.constraint(equalToConstant: 25),
        ])
    }
    
    private func setupLogoutBtn() {
        addSubview(logoutBtn)
        NSLayoutConstraint.activate([
            logoutBtn.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            logoutBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8)
        ])
    }
    
    private func setupFeedLabel() {
        addSubview(feedLabel)
        NSLayoutConstraint.activate([
            feedLabel.topAnchor.constraint(equalTo: logoutBtn.bottomAnchor, constant: 8),
            feedLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8)
        ])
    }
    
    private func setupPostsTableView(){
        addSubview(postsCollection)
        NSLayoutConstraint.activate([
            postsCollection.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            postsCollection.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            postsCollection.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            postsCollection.topAnchor.constraint(equalTo: feedLabel.bottomAnchor, constant: 2),
            postsCollection.bottomAnchor.constraint(equalTo: friendsBtn.topAnchor, constant: 0),
            postsCollection.widthAnchor.constraint(equalToConstant: self.frame.width),
        ])
    }
    
    private func setupFriendsBtn(){
        addSubview(friendsBtn)
        NSLayoutConstraint.activate([
            friendsBtn.leadingAnchor.constraint(equalTo: logoutBtn.leadingAnchor),
            friendsBtn.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupRefreshBtn(){
        addSubview(refreshButton)
        NSLayoutConstraint.activate([
            refreshButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            refreshButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            refreshButton.widthAnchor.constraint(equalToConstant: 20),
            refreshButton.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    private func setupLoadingAnimation() {
        addSubview(loadingAnimation)
        NSLayoutConstraint.activate([
            loadingAnimation.heightAnchor.constraint(equalToConstant: 200),
            loadingAnimation.widthAnchor.constraint(equalToConstant: 200),
            loadingAnimation.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loadingAnimation.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    //MARK: Gradient background
    func setGradientBackground(){
        let topColor = UIColor.appPink.cgColor
        let bottomColor = UIColor.appPurple.cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.main.bounds
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }

    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        setGradientBackground()
        setupAddPostBtn()
        setupLogoutBtn()
        setupFeedLabel()
        setupFriendsBtn()
        setupPostsTableView()
        setupRefreshBtn()
        setupLoadingAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Handlers
    @objc func handleFriends() {
        delegate?.handleFriends()
    }
    
    @objc func handleLogout() {
        delegate?.handleLogout()
    }
    
    @objc func handleAddPost() {
        delegate?.handleAddPost()
    }
    
    @objc func handleRefresh(){
        delegate?.handleRefresh()
    }
}
