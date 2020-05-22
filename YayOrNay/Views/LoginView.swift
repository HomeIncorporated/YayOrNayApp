//
//  LoginView.swift
//  YayOrNay
//
//  Created by Ilay on 01/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit

protocol LoginDelegate {
    func handleLogin()
    func handleSignup()
}

class LoginView: UIView {

    var delegate: LoginDelegate?

    let logoView: UIImageView =  {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.image = UIImage(named: "appLogo")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    //MARK: Email Textfield
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

    //MARK: Password Textfield
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

    //MARK: LoginBtn
    fileprivate let loginBtn: CustomAnimateButton = {
        let btn = CustomAnimateButton(type: .system)
        btn.mainColor = UIColor.appOrange
        btn.accentColor = UIColor.appOrangeDarker
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor.appOrange
        btn.setTitle(NSLocalizedString("login.btn", comment: "Login"), for: .normal)
        btn.setTitleColor(UIColor.appWhite, for: .normal)
        //btn.setBackgroundColor(UIColor.appWhite, for: .highlighted)
        btn.layer.cornerRadius = 10
        btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        btn.layer.shadowOpacity = 0.40
        btn.layer.shadowRadius = 5.0
        btn.layer.masksToBounds = false

        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return btn
    }()

    //MARK: SignupBtn
    fileprivate let signupBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitle(NSLocalizedString("signup.btn", comment: "signup"), for: .normal)
        btn.setTitleColor(UIColor.appWhite, for: .normal)

        btn.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setGradientBackground()
        setLogoView()
        setSignupBtn()
        setEmailTextfield()
        setPasswordTextfield()
        setLoginBtn()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    //MARK: UI Setting
    
    private func setLogoView() {
        addSubview(logoView)
        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            logoView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            logoView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            logoView.widthAnchor.constraint(equalToConstant: 200),
            logoView.heightAnchor.constraint(equalToConstant: 200),
            logoView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 40),
        ])
    }
    
    private func setLoginBtn(){
        addSubview(loginBtn)
        NSLayoutConstraint.activate([
            loginBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loginBtn.topAnchor.constraint(equalTo: passTxtField.bottomAnchor, constant: 30),
            loginBtn.heightAnchor.constraint(equalToConstant: 40),
            loginBtn.widthAnchor.constraint(equalToConstant: 150),
            ])
    }

    private func setSignupBtn(){
        addSubview(signupBtn)
        NSLayoutConstraint.activate([
            signupBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            signupBtn.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -5)
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

    private func setPasswordTextfield(){
        addSubview(passTxtField)
        NSLayoutConstraint.activate([
            passTxtField.topAnchor.constraint(equalTo: emailTxtField.bottomAnchor, constant: 8),
            passTxtField.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            passTxtField.heightAnchor.constraint(equalToConstant: 40),
            passTxtField.widthAnchor.constraint(equalToConstant: 250),
            ])
    }

    @objc func handleLogin(){
        delegate?.handleLogin()
    }

    @objc func handleSignup(){
        delegate?.handleSignup()
    }
}
