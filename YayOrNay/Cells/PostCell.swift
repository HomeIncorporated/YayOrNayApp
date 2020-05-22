//
//  PostCell.swift
//  YayOrNay
//
//  Created by Ilay on 03/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit

class PostCell: UICollectionViewCell {
    
    let postId: String = ""
    
    //Animating the cell on tap
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
                    self.transform = self.transform.scaledBy(x: 0.95, y: 0.95)
                }, completion: nil)
            }else {
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
                    self.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
                }, completion: nil)
            }
        }
    }
    
    //MARK: Post title
    let postTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.appWhite
        label.isUserInteractionEnabled = false
        

        return label
    }()

    //MARK: Upvote button
    let upvotePostBtn: CustomAnimateButton = {
        let btn = CustomAnimateButton(type: .custom)
        btn.setImage(UIImage(named: "upvote"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false

        return btn
    }()

    let upvoteScoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.appWhite
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    //MARK: Downvote button
    let downvotePostBtn: CustomAnimateButton = {
        let btn = CustomAnimateButton(type: .custom)
        
        btn.setImage(UIImage(named: "downvote"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false

        return btn
    }()

    //MARK: Downvote label
    let downvoteScoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.appWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    //MARK: Cell User's Image
    let cellImage: CustomUIImageView = {
        let image = CustomUIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isUserInteractionEnabled = true
        image.clipsToBounds = true
        image.layer.cornerRadius = 10
        image.contentMode = .scaleAspectFill
        
        return image
    }()

    //MARK: scoreView
    let scoreDimView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.4)
        view.layer.zPosition = 1
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.appWhiteAccent
        self.setCornerAndShadow()
        
        setCellImage()
        setupDimView()
        setPostTitle()
        setupDownvoteLabel()
        setupDownvotePostBtn()
        setupUpvoteLabel()
        setupUpvotePostBtn()

        self.sendSubviewToBack(cellImage)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: Set scoreDimView
    fileprivate func setupDimView() {
        addSubview(scoreDimView)
        NSLayoutConstraint.activate([
            scoreDimView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            scoreDimView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scoreDimView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scoreDimView.widthAnchor.constraint(equalToConstant: self.frame.width),
            scoreDimView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    //MARK: Set post title
    fileprivate func setPostTitle(){
        scoreDimView.addSubview(postTitle)
        NSLayoutConstraint.activate([
            postTitle.centerYAnchor.constraint(equalTo: scoreDimView.centerYAnchor),
            postTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            postTitle.widthAnchor.constraint(equalToConstant: self.frame.width - 10)
        ])
    }
    

    //MARK: Setup Post Downvote and Upvote icons and labels
    fileprivate func setupDownvoteLabel() {
        scoreDimView.addSubview(downvoteScoreLabel)
        NSLayoutConstraint.activate([
            downvoteScoreLabel.centerYAnchor.constraint(equalTo: scoreDimView.centerYAnchor),
            downvoteScoreLabel.trailingAnchor.constraint(equalTo: scoreDimView.trailingAnchor, constant: -8),
            downvoteScoreLabel.widthAnchor.constraint(equalToConstant: 18),
        ])
    }
    
    fileprivate func setupDownvotePostBtn() {
        scoreDimView.addSubview(downvotePostBtn)
        NSLayoutConstraint.activate([
            downvotePostBtn.centerYAnchor.constraint(equalTo: scoreDimView.centerYAnchor),
            downvotePostBtn.heightAnchor.constraint(equalToConstant: 20),
            downvotePostBtn.widthAnchor.constraint(equalToConstant: 20),
            downvotePostBtn.trailingAnchor.constraint(equalTo: downvoteScoreLabel.leadingAnchor, constant: -5),
        ])
    }
    
    fileprivate func setupUpvoteLabel() {
        scoreDimView.addSubview(upvoteScoreLabel)
        NSLayoutConstraint.activate([
            upvoteScoreLabel.centerYAnchor.constraint(equalTo: scoreDimView.centerYAnchor),
            upvoteScoreLabel.trailingAnchor.constraint(equalTo: downvotePostBtn.leadingAnchor, constant: -16),
            upvoteScoreLabel.widthAnchor.constraint(equalToConstant: 18),
        ])
    }
    
    fileprivate func setupUpvotePostBtn() {
        scoreDimView.addSubview(upvotePostBtn)
        NSLayoutConstraint.activate([
            upvotePostBtn.centerYAnchor.constraint(equalTo: scoreDimView.centerYAnchor),
            upvotePostBtn.heightAnchor.constraint(equalToConstant: 20),
            upvotePostBtn.widthAnchor.constraint(equalToConstant: 20),
            upvotePostBtn.trailingAnchor.constraint(equalTo: upvoteScoreLabel.leadingAnchor, constant: -5),
        ])
    }
    
    //MARK: Set image
    fileprivate func setCellImage(){
        addSubview(cellImage)
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: self.topAnchor),
            cellImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            cellImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cellImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}
