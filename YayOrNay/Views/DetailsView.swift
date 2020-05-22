//
//  DetailsView.swift
//  YayOrNay
//
//  Created by Ilay on 28/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit

protocol detailsDelegate {
    func handleFollow()
}

class DetailsView: UIView {
    
    var delegate: detailsDelegate?
    
    var isFriend: Bool = false {
        didSet {
            if isFriend == false {
                followBtn.setTitle(NSLocalizedString("friend.btn", comment: "follow"), for: .normal)
                followBtn.backgroundColor = .appPurple
            } else {
                followBtn.setTitle(NSLocalizedString("unfriend.btn", comment: "unfollow"), for: .normal)
                followBtn.backgroundColor = .appOrange
            }
        }
    }
    
    let dismissIndicator: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appWhite
        view.layer.cornerRadius = 15
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        let dismissImg = UIImageView(image: UIImage(named: "closeArrow"))
        dismissImg.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(dismissImg)
        
        dismissImg.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dismissImg.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    private let userProfileView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appWhite

        return view
    }()

    let profileImg: CustomUIImageView = {
        let img = CustomUIImageView(image: UIImage(named: "profileplaceholder"))
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        img.layer.masksToBounds = true

        img.heightAnchor.constraint(equalToConstant: 40).isActive = true
        img.widthAnchor.constraint(equalToConstant: 40).isActive = true
        img.layoutIfNeeded()

        img.layer.borderWidth = 1.0
        img.layer.borderColor = UIColor.appTurquoise.cgColor

        img.layer.cornerRadius = img.frame.width / 2
        img.contentMode = .scaleAspectFill
        return img
    }()

    let userProfileName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "USERNAME"
        label.textColor = UIColor.appTurquoise

        return label
    }()

    private let postDetailsView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appWhite

        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 2.0
        view.layer.masksToBounds = false

        return view
    }()

    let postTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "POST TITLE"
        label.textColor = UIColor.appTurquoise

        return label
    }()

    let postOccasion: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "Casual"
        label.textColor = UIColor.appBlack

        return label
    }()

    let followBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 50).isActive = true

        btn.backgroundColor = UIColor.appPurple
        btn.setTitle(NSLocalizedString("follow.btn", comment: "follow"), for: .normal)
        btn.setTitleColor(UIColor.appWhite, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        btn.setBackgroundColor(UIColor.appWhite, for: .highlighted)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        btn.layer.cornerRadius = 10

        return btn
    }()

    let postImage: CustomUIImageView = {
        let img = CustomUIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        img.backgroundColor = .red
        img.clipsToBounds = true

        img.translatesAutoresizingMaskIntoConstraints = false
        img.isUserInteractionEnabled = false
        img.contentMode = .scaleAspectFill

        return img
    }()

    private let upvoteImage: UIImageView = {
        let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        img.image = UIImage(named: "upvoteDark")
        img.clipsToBounds = true
        img.isUserInteractionEnabled = false
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    
    let upvotesLabel: UILabel = {
        let label = UILabel()
        label.text = "10"
        label.isUserInteractionEnabled = false
        label.textColor = UIColor.appBlack
        label.font = UIFont.boldSystemFont(ofSize: 12)
        
        return label
    }()
    
    private let downvoteImage: UIImageView = {
        let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        img.image = UIImage(named: "downvoteDark")
        img.clipsToBounds = true
        img.isUserInteractionEnabled = false
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    
    let downvotesLabel: UILabel = {
        let label = UILabel()
        label.text = "10"
        label.isUserInteractionEnabled = false
        label.textColor = UIColor.appBlack
        label.font = UIFont.boldSystemFont(ofSize: 12)
        
        return label
    }()
    
    private lazy var masterStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.upvoteImage, self.upvotesLabel, self.downvoteImage, self.downvotesLabel])
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.spacing = 2
        
        return stack
    }()
    
    let postBodyTextView: UITextView = {
        let view = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appWhite
        view.textAlignment = NSTextAlignment.natural
        view.textColor = UIColor.appBlack
        view.tintColor = UIColor.appBlack
        view.isEditable = false
        
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.appWhite
        self.layer.cornerRadius = 15
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
        setupDismissIndicator()
        setupUserProfileView()
        setupProfileImg()
        setupUsernameLabel()
        setupFollowBtn()
        setupPostImg()
        setupPostDetailView()
        setupPostTitle()
        setupPostOccasion()
        setupMasterStack()
        setupPostBodyTextView()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: SETUP Dismiss Indicator
    private func setupDismissIndicator() {
        addSubview(dismissIndicator)
        NSLayoutConstraint.activate([
            dismissIndicator.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            dismissIndicator.widthAnchor.constraint(equalToConstant: self.frame.width),
            dismissIndicator.heightAnchor.constraint(equalToConstant: 50),
            dismissIndicator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dismissIndicator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    //MARK: SETUP PROFILEVIEW
    private func setupUserProfileView(){
        addSubview(userProfileView)
        NSLayoutConstraint.activate([
            userProfileView.topAnchor.constraint(equalTo: dismissIndicator.bottomAnchor),
            userProfileView.widthAnchor.constraint(equalToConstant: self.frame.width),
            userProfileView.heightAnchor.constraint(equalToConstant: 65),
            userProfileView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            userProfileView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            ])
    }

    //MARK: SETUP PROFILE IMG
    private func setupProfileImg(){
        userProfileView.addSubview(profileImg)
        NSLayoutConstraint.activate([
            profileImg.leadingAnchor.constraint(equalTo: userProfileView.leadingAnchor, constant: 15),
            profileImg.centerYAnchor.constraint(equalTo: userProfileView.centerYAnchor),

            ])
    }

    //MARK: SETUP USERNAME LABEL
    private func setupUsernameLabel(){
        userProfileView.addSubview(userProfileName)
        NSLayoutConstraint.activate([
            userProfileName.centerYAnchor.constraint(equalTo: profileImg.centerYAnchor),
            userProfileName.leadingAnchor.constraint(equalTo: profileImg.trailingAnchor, constant: 5),
            ])
    }

    //MARK: SETUP FOLLOW BUTTON
    private func setupFollowBtn(){
        userProfileView.addSubview(followBtn)
        NSLayoutConstraint.activate([
            followBtn.heightAnchor.constraint(equalToConstant: 20),
            followBtn.centerYAnchor.constraint(equalTo: userProfileView.centerYAnchor),
            followBtn.trailingAnchor.constraint(equalTo: userProfileView.trailingAnchor, constant: -15)
            ])
    }

    //MARK: SETUP POST IMAGE
    private func setupPostImg(){
        addSubview(postImage)
        NSLayoutConstraint.activate([
            postImage.topAnchor.constraint(equalTo: userProfileView.bottomAnchor, constant: 0),
            postImage.widthAnchor.constraint(equalToConstant: self.frame.width),
            postImage.heightAnchor.constraint(equalToConstant: 300),
            postImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            postImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            postImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            ])
    }

    private func setupPostDetailView(){
        addSubview(postDetailsView)
        NSLayoutConstraint.activate([
            postDetailsView.topAnchor.constraint(equalTo: postImage.bottomAnchor),
            postDetailsView.widthAnchor.constraint(equalToConstant: self.frame.width),
            postDetailsView.heightAnchor.constraint(equalToConstant: 65),
            postDetailsView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            postDetailsView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            ])
    }

    private func setupPostTitle(){
        postDetailsView.addSubview(postTitle)
        NSLayoutConstraint.activate([
            postTitle.topAnchor.constraint(equalTo: postDetailsView.topAnchor, constant: 5),
            postTitle.leadingAnchor.constraint(equalTo: postDetailsView.leadingAnchor, constant: 5),
        ])
    }

    private func setupPostOccasion(){
        postDetailsView.addSubview(postOccasion)
        NSLayoutConstraint.activate([
            postOccasion.topAnchor.constraint(equalTo: postTitle.bottomAnchor, constant: 5),
            postOccasion.leadingAnchor.constraint(equalTo: postTitle.leadingAnchor),
        ])
    }

    private func setupMasterStack(){
        postDetailsView.addSubview(masterStack)
        NSLayoutConstraint.activate([
            masterStack.widthAnchor.constraint(equalToConstant: 100),
            masterStack.heightAnchor.constraint(equalToConstant: 20),
            masterStack.trailingAnchor.constraint(equalTo: postDetailsView.trailingAnchor, constant: -5),
            masterStack.topAnchor.constraint(equalTo: postDetailsView.topAnchor, constant: 20),

        ])
    }
    
    private func setupPostBodyTextView() {
        addSubview(postBodyTextView)
        NSLayoutConstraint.activate([
            postBodyTextView.topAnchor.constraint(equalTo: masterStack.bottomAnchor),
            postBodyTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            postBodyTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            postBodyTextView.widthAnchor.constraint(equalToConstant: self.frame.size.width),
            postBodyTextView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    //MARK: Handlers
    @objc func handleFollow() {
        delegate?.handleFollow()
    }
}
