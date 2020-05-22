//
//  SignupView.swift
//  YayOrNay
//
//  Created by Ilay on 11/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit
import Lottie

protocol signupDelegate {
    func handleSignup()
    func handleProfileImg()
    func handleBackToLogin()
}

class SignupView: UIView {

    var delegate: signupDelegate?
    
    //MARK: Properties
    let profileImage: UIImageView = {
        let img = UIImageView(image: UIImage(named: "profileplaceholder"))
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        img.layer.masksToBounds = true
        
        img.heightAnchor.constraint(equalToConstant: 100).isActive = true
        img.widthAnchor.constraint(equalToConstant: 100).isActive = true
        img.layoutIfNeeded()
        
        img.layer.borderWidth = 3.0
        img.layer.borderColor = UIColor(hexString: "#F2F7F2", alpha: 0.5).cgColor
        
        img.layer.cornerRadius = img.frame.width / 2
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    
    let emailTxtField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.backgroundColor = .clear
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.appWhite.cgColor
        field.layer.cornerRadius = 20

        field.textColor = UIColor.appWhite
        field.keyboardType = .emailAddress
        field.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("email.placeholder", comment: "email address"),
                                                         attributes: [NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#F2F7F2", alpha: 0.5)])
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 1))
        field.leftView = padding
        field.leftViewMode = .always


        field.rightView = padding
        field.rightViewMode = .always
        field.tintColor = .clear
        return field
    }()

    let usernameTxtField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.backgroundColor = .clear
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.appWhite.cgColor
        field.layer.cornerRadius = 20

        field.textColor = UIColor.appWhite
        field.keyboardType = UIKeyboardType.alphabet
        field.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("username.placeholder", comment: "username"), attributes: [NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#F2F7F2", alpha: 0.5)])

        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 1))
        field.leftView = padding
        field.leftViewMode = .always


        field.rightView = padding
        field.rightViewMode = .always
        field.tintColor = .clear
        return field
    }()

    let passTxtField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.backgroundColor = .clear
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.appWhite.cgColor
        field.layer.cornerRadius = 20
        field.isSecureTextEntry = true

        field.textColor = UIColor.appWhite
        field.keyboardType = .default
        field.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("password.placeholder", comment: "password"), attributes: [NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#F2F7F2", alpha: 0.5)])

        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 1))
        field.leftView = padding
        field.leftViewMode = .always

        field.rightView = padding
        field.rightViewMode = .always
        field.tintColor = .clear
        return field
    }()

    let approvePassTxtField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.backgroundColor = .clear
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.appWhite.cgColor
        field.layer.cornerRadius = 20
        field.isSecureTextEntry = true

        field.textColor = UIColor.appWhite
        field.keyboardType = .default
        field.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("app.pass.placeholder", comment: "password"), attributes: [NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#F2F7F2", alpha: 0.5)])

        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 1))
        field.leftView = padding
        field.leftViewMode = .always

        field.rightView = padding
        field.rightViewMode = .always
        field.tintColor = .clear
        return field
    }()

    fileprivate let signupBtn: CustomAnimateButton = {
        let btn = CustomAnimateButton(type: .system)
        btn.mainColor = UIColor.appOrange
        btn.mainColor = UIColor.appOrangeDarker
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor.appOrange
        btn.setTitle(NSLocalizedString("signup.form.btn", comment: "Signup"), for: .normal)
        btn.setTitleColor(UIColor.appWhite, for: .normal)
        btn.setBackgroundColor(UIColor.appWhite, for: .highlighted)
        btn.layer.cornerRadius = 10
        btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        btn.layer.shadowOpacity = 0.40
        btn.layer.shadowRadius = 5.0
        btn.layer.masksToBounds = false

        btn.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        return btn
    }()

    fileprivate let backToLoginBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitle(NSLocalizedString("back.to.login", comment: "login"), for: .normal)
        btn.setTitleColor(UIColor.appWhite, for: .normal)
        
        btn.addTarget(self, action: #selector(handleBackToLogin), for: .touchUpInside)
        return btn
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setGradientBackground()
        setEmailTextfield()
        setProfileImage()
        setUsernameTextfield()
        setPasswordTextfield()
        setApprovePasswordTextfield()
        setSignupBtn()
        setBackToLoginBtn()
        setupLoadingAnimation()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleProfileImg))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UI Setting
    private func setGradientBackground(){
        let topColor = UIColor.appPink.cgColor
        let bottomColor = UIColor.appPurple.cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.main.bounds
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setProfileImage() {
        addSubview(profileImage)
        NSLayoutConstraint.activate([
            profileImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            profileImage.bottomAnchor.constraint(equalTo: emailTxtField.topAnchor, constant: -50),
        ])
    }
    
    private func setSignupBtn(){
        addSubview(signupBtn)
        NSLayoutConstraint.activate([
            signupBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            signupBtn.topAnchor.constraint(equalTo: approvePassTxtField.bottomAnchor, constant: 30),
            signupBtn.heightAnchor.constraint(equalToConstant: 40),
            signupBtn.widthAnchor.constraint(equalToConstant: 150),
            ])
    }

    private func setEmailTextfield(){
        addSubview(emailTxtField)
        NSLayoutConstraint.activate([
            emailTxtField.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            emailTxtField.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            emailTxtField.heightAnchor.constraint(equalToConstant: 40),
            emailTxtField.widthAnchor.constraint(equalToConstant: 250),
            ])
    }

    private func setUsernameTextfield(){
        addSubview(usernameTxtField)
        NSLayoutConstraint.activate([
            usernameTxtField.topAnchor.constraint(equalTo: emailTxtField.bottomAnchor, constant: 8),
            usernameTxtField.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            usernameTxtField.heightAnchor.constraint(equalToConstant: 40),
            usernameTxtField.widthAnchor.constraint(equalToConstant: 250),
            ])
    }

    private func setPasswordTextfield(){
        addSubview(passTxtField)
        NSLayoutConstraint.activate([
            passTxtField.topAnchor.constraint(equalTo: usernameTxtField.bottomAnchor, constant: 8),
            passTxtField.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            passTxtField.heightAnchor.constraint(equalToConstant: 40),
            passTxtField.widthAnchor.constraint(equalToConstant: 250),
            ])
    }

    private func setApprovePasswordTextfield(){
         addSubview(approvePassTxtField)
        NSLayoutConstraint.activate([
            approvePassTxtField.topAnchor.constraint(equalTo: passTxtField.bottomAnchor, constant: 8),
            approvePassTxtField.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            approvePassTxtField.heightAnchor.constraint(equalToConstant: 40),
            approvePassTxtField.widthAnchor.constraint(equalToConstant: 250),
        ])
    }
    
    private func setBackToLoginBtn() {
        addSubview(backToLoginBtn)
        NSLayoutConstraint.activate([
            backToLoginBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            backToLoginBtn.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -5)
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
    
    @objc func handleSignup(){
        delegate?.handleSignup()
    }
    
    @objc func handleProfileImg() {
        delegate?.handleProfileImg()
    }
    
    @objc func handleBackToLogin() {
        delegate?.handleBackToLogin()
    }
    
}
