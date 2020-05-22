//
//  ViewController.swift
//  YayOrNay
//
//  Created by Ilay on 01/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {

    let mView = LoginView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .blackOpaque
        if UserDefaults.standard.object(forKey: USER_UID_KEY) != nil {
            self.navigationController?.popToViewController(PostsVC(), animated: true)
        }
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.mView.emailTxtField.text = ""
        self.mView.passTxtField.text = ""
    }

    override func loadView() {
        super.loadView()
        self.view = mView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mView.delegate = self
        self.mView.emailTxtField.delegate = self
        self.mView.passTxtField.delegate = self

    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: handlers
extension LoginVC: LoginDelegate {
    func handleLogin() {
        guard let email = self.mView.emailTxtField.text else { return }
        guard let pass = self.mView.passTxtField.text else { return }

        FirestoreService.shared.loginUser(email, pass) { (userLogged, error) in
            if userLogged && error == nil {
                UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey:     USER_UID_KEY)
                let vc = PostsVC()

                let transition = CATransition()
                transition.duration = 0.5
                transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                transition.type = .push
                transition.subtype = .fromTop
                self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                self.navigationController?.pushViewController(vc, animated: false)
            }else {
                guard let err = error?.localizedDescription as? String else { return }
                let ac = UIAlertController(title: NSLocalizedString("error", comment: "Oops"), message: "\(err)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: NSLocalizedString("understand", comment: "I understand"), style: .default, handler: nil))
                self.present(ac, animated: true)
            }
        }
    }

    func handleSignup() {
        let vc = SignupVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
