//
//  NewpostView.swift
//  YayOrNay
//
//  Created by Ilay on 04/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import Foundation
import UIKit
import Lottie

private var cellWidth: CGFloat = 0.0
private var cellHeight: CGFloat = 0.0

protocol NewPostViewDelegate {
    func handleSubmit()
    func handleTagChosen(_ sender: UIButton)
}

enum Scenario: Int {
    case casual = 0
    case beach = 1
    case evening = 2
    case party = 3
    case date = 4
    case work = 5
}

class NewPostView: UIView {

    var delegate: NewPostViewDelegate?
    
    //MARK: Properties
    let postView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appWhite
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 5
        
        return view
    }()

    let postTitle: UITextField = {
        let field = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        field.translatesAutoresizingMaskIntoConstraints = false
        field.backgroundColor = .appWhite
        field.textAlignment = NSTextAlignment.natural
        field.textColor = UIColor.appBlack
        field.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("post.title.placeholder", comment: "title"), attributes: [NSAttributedString.Key.foregroundColor: UIColor.appBlack])
        
        //Adding padding to both sides, so if we have RTL language it will still have the padding effect.
        field.setLeftPadding(with: 8)
        field.setRightPadding(with: 8)
        
        field.tintColor = UIColor.appBlack

        return field
    }()

    let postImage: UIImageView = {
        let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill

        return img
    }()

    let imagePlaceholder: UIImageView = {
        let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        img.translatesAutoresizingMaskIntoConstraints = false
        img.image = UIImage(named: "addImage")
        img.contentMode = .scaleAspectFit

        
        return img
    }()

    let tagLabel: UILabel = {
        let lbl = UILabel()
        lbl.isUserInteractionEnabled = false
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        lbl.text = NSLocalizedString("occasion.label", comment: "tag")
        lbl.textColor = UIColor.appTurquoise

        return lbl
    }()
    
    let saySomethingTextview: UITextView = {
        let view = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appWhite
        view.textAlignment = NSTextAlignment.natural
        view.textColor = UIColor.appBlack
        
        view.tintColor = UIColor.appBlack
        
        return view
    }()
    
    let textViewPlaceholder: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.natural
        label.text = NSLocalizedString("post.body.placeholder", comment: "placeholder text")
        label.textColor = .lightGray
        
        return label
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
    
    //MARK: Tag Buttons
    let casualBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 10
        btn.backgroundColor = UIColor.appTurquoise
        btn.setTitleColor(UIColor.appWhite, for: .normal)
        btn.setTitle(NSLocalizedString("casual", comment: "casual"), for: .normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
                btn.addTarget(self, action: #selector(NewpostVC.handleTagChosen(_:)), for: .touchUpInside)
        btn.tag = 0

        return btn
    }()

    let beachBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 10
        btn.backgroundColor = UIColor.appWhiteAccent
        btn.setTitleColor(UIColor.appBlack, for: .normal)
        btn.setTitle(NSLocalizedString("beach", comment: "beach"), for: .normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.addTarget(self, action: #selector(NewpostVC.handleTagChosen(_:)), for: .touchUpInside)
        btn.tag = 1

        return btn
    }()

    let eveningBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 10
        btn.backgroundColor = UIColor.appWhiteAccent
        btn.setTitleColor(UIColor.appBlack, for: .normal)
        btn.setTitle(NSLocalizedString("evening", comment: "evening"), for: .normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.addTarget(self, action: #selector(NewpostVC.handleTagChosen(_:)), for: .touchUpInside)
        btn.tag = 2

        return btn
    }()

    let partyBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 10
        btn.backgroundColor = UIColor.appWhiteAccent
        btn.setTitleColor(UIColor.appBlack, for: .normal)
        btn.setTitle(NSLocalizedString("party", comment: "party"), for: .normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.addTarget(self, action: #selector(NewpostVC.handleTagChosen(_:)), for: .touchUpInside)
        btn.tag = 3

        return btn
    }()

    let dateBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 10
        btn.backgroundColor = UIColor.appWhiteAccent
        btn.setTitleColor(UIColor.appBlack, for: .normal)
        btn.setTitle(NSLocalizedString("date", comment: "date"), for: .normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.addTarget(self, action: #selector(NewpostVC.handleTagChosen(_:)), for: .touchUpInside)
        btn.tag = 4

        return btn
    }()

    let weddingBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 10
        btn.backgroundColor = UIColor.appWhiteAccent
        btn.setTitleColor(UIColor.appBlack, for: .normal)
        btn.setTitle(NSLocalizedString("wedding", comment: "wedding"), for: .normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.addTarget(self, action: #selector(NewpostVC.handleTagChosen(_:)), for: .touchUpInside)
        btn.tag = 5

        return btn
    }()

    let workBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 10
        btn.backgroundColor = UIColor.appWhiteAccent
        btn.setTitleColor(UIColor.appBlack, for: .normal)
        btn.setTitle(NSLocalizedString("work", comment: "work"), for: .normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.addTarget(self, action: #selector(NewpostVC.handleTagChosen(_:)), for: .touchUpInside)
        btn.tag = 6

        return btn
    }()

    
    lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.casualBtn, self.beachBtn, self.eveningBtn, self.partyBtn, self.dateBtn, self.workBtn])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 2

        return stack
        
    }()

    //MARK: UI Settings
    
    private func setupPostView() {
        addSubview(postView)
        NSLayoutConstraint.activate([
            postView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 40),
            postView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            postView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            postView.widthAnchor.constraint(equalToConstant: self.frame.width),
            postView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    fileprivate func setupPostTitle(){
        addSubview(postTitle)
        NSLayoutConstraint.activate([
            postTitle.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            postTitle.widthAnchor.constraint(equalToConstant: self.frame.size.width),
            postTitle.heightAnchor.constraint(equalToConstant: 40),
            postTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            postTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    fileprivate func setupPostImage(){
        postView.addSubview(postImage)
        NSLayoutConstraint.activate([
            postImage.widthAnchor.constraint(equalToConstant: postView.frame.size.width),
            postImage.heightAnchor.constraint(equalToConstant: postView.frame.size.height - postTitle.frame.size.height),
            postImage.widthAnchor.constraint(equalToConstant: postView.frame.size.width),
            postImage.bottomAnchor.constraint(equalTo: postView.bottomAnchor),
            postImage.topAnchor.constraint(equalTo: postView.topAnchor),
            postImage.leadingAnchor.constraint(equalTo: postView.leadingAnchor),
            postImage.trailingAnchor.constraint(equalTo: postView.trailingAnchor),
        ])
    }

    fileprivate func setupImagePlaceholder(){
        postView.addSubview(imagePlaceholder)
        NSLayoutConstraint.activate([
            imagePlaceholder.centerXAnchor.constraint(equalTo: postView.centerXAnchor),
            imagePlaceholder.centerYAnchor.constraint(equalTo: postView.centerYAnchor),
            imagePlaceholder.widthAnchor.constraint(equalToConstant: 70),
            imagePlaceholder.heightAnchor.constraint(equalToConstant: 70),
            ])
    }

    private func setupSaySomethingTextview(){
        addSubview(saySomethingTextview)
        NSLayoutConstraint.activate([
            saySomethingTextview.topAnchor.constraint(equalTo: postView.bottomAnchor),
            saySomethingTextview.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            saySomethingTextview.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            saySomethingTextview.widthAnchor.constraint(equalToConstant: self.frame.size.width),
            saySomethingTextview.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    private func setuptextViewPlaceholder() {
        saySomethingTextview.addSubview(textViewPlaceholder)
        NSLayoutConstraint.activate([
            textViewPlaceholder.leadingAnchor.constraint(equalTo: saySomethingTextview.leadingAnchor, constant: 5),
            textViewPlaceholder.topAnchor.constraint(equalTo: saySomethingTextview.topAnchor, constant: 5),
        ])
    }
    
    fileprivate func setupTagLabel(){
        addSubview(tagLabel)
        NSLayoutConstraint.activate([
            tagLabel.leadingAnchor.constraint(equalTo: buttonsStack.leadingAnchor),
            tagLabel.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -8),
        ])
    }

    fileprivate func setupBtnsStack(){
        addSubview(buttonsStack)
        NSLayoutConstraint.activate([
            buttonsStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            buttonsStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            buttonsStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            buttonsStack.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -16),
            buttonsStack.heightAnchor.constraint(equalToConstant: 40),
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.appWhite
        
        setupPostView()
        setupPostTitle()
        setupImagePlaceholder()
        setupSaySomethingTextview()
        setuptextViewPlaceholder()
        setupBtnsStack()
        setupTagLabel()
        setupPostImage()
        setupLoadingAnimation()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //MARK: Handle functions
    @objc fileprivate func handleSubmit(){
        delegate?.handleSubmit()
    }

    @objc fileprivate func handleTagChosen(_ sender: UIButton) {
        delegate?.handleTagChosen(sender)
    }
}
