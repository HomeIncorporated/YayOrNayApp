//
//  SignupVC.swift
//  YayOrNay
//
//  Created by Ilay on 10/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Lottie

class SignupVC: UIViewController {
    
    let mView = SignupView()
    let db = Firestore.firestore()
    
    var imageChoosen: Bool = false // Indicates if the user chose image or not.
    var imageName: String = ""
    var imagePicker: ImagePicker!
    var imageToUpload: UIImage? = UIImage(named: "profileplaceholder")
    var imageUrl: String?
    
    override func loadView() {
        super.loadView()
        self.view = mView
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mView.delegate = self

        imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
}

extension SignupVC: signupDelegate {
    
    func handleSignup() {
        
        guard let email = self.mView.emailTxtField.text?.lowercased() else { return }
        guard let pass = self.mView.passTxtField.text else { return }
        guard let approvePass = self.mView.approvePassTxtField.text else { return }
        guard let username = self.mView.usernameTxtField.text?.lowercased() else { return }
        
        if pass == approvePass {
            FirestoreService.shared.checkForUsernameExists(username) { (usernameAvailable) in
                if usernameAvailable {
                    self.startLoadingAnimation()
                    DispatchQueue.global(qos: .userInitiated).async {
                        let group = DispatchGroup()
                        group.enter()
                        FirestoreService.shared.uploadImageToFirebase(self.imageToUpload, completion: { (imageUrl) in
                            guard let url = imageUrl else { return }
                            self.imageUrl = url
                            group.leave()
                        })
                        group.wait()
                        FirestoreService.shared.signupUser(email, pass, username) { (userCreated, err) in
                            if userCreated && err == nil {
                                self.stopLoadingAnimation()
                                UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: USER_UID_KEY)
                                
                                let user_id = Auth.auth().currentUser!.uid //force unwrapping because we already checked is not nil.
                                let newUser = User(user_id, email, username, self.imageUrl ?? "", [], [:]) //self.registerUser(Auth.auth().currentUser!.uid, username, email, self.imageUrl ?? "")
                                self.registerUser(newUser)
                                let vc = LoginVC()
                                self.navigationController?.popViewController(animated: false)
                                self.navigationController?.pushViewController(vc, animated: true)
                            }else {
                                let ac = UIAlertController(title: NSLocalizedString("error", comment: "oops"), message: "\(err!.localizedDescription)" , preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: NSLocalizedString("understand", comment: "understand"), style: .default, handler: { (action) in
                                    self.stopLoadingAnimation()
                                }))
                                self.present(ac, animated: true)
                            }
                        }
                    }
                }else {
                    let ac = UIAlertController(title: NSLocalizedString("error", comment: "oops"), message: NSLocalizedString("username.taken", comment: "taken"), preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: NSLocalizedString("understand", comment: "understand"), style: .default, handler: { (action) in
                    }))
                    self.present(ac, animated: true)
                }
            }
        }else {
            let ac = UIAlertController(title: NSLocalizedString("pass.dont.match.title", comment: "pass"), message: NSLocalizedString("pass.dont.match.msg", comment: "msg"), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("understand", comment: "understand"), style: .default, handler: nil))
            self.present(ac, animated: true)
        }
    }
    func handleProfileImg() {
        self.imagePicker.present(from: self.mView)
    }
    
    func handleBackToLogin() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SignupVC: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        if image != nil {
            self.mView.profileImage.image = image
            self.imageChoosen = true
            self.imageToUpload = image
        }
    }
}

//MARK: Helper functions
extension SignupVC {
    
    func registerUser(_ user: User) {
        FirestoreService.shared.addNewUserToDatabase(user) { (added) in
            if added {
                return
            }
        }
    }
//    func registerUser(_ uid: String, _ username: String, _ userEmail: String, _ profileImg: String) {
//        FirestoreService.shared.addUserToDatabase(uid, username, userEmail, profileImg) { (userAdded, err) in
//            if userAdded && err == nil {
//                return
//            }else {
//                let ac = UIAlertController(title: NSLocalizedString("error", comment: "oops"), message: "\(err!.localizedDescription)" , preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: NSLocalizedString("understand", comment: "I understand"), style: .default, handler: nil))
//                self.present(ac, animated: true)
//            }
//        }
//    }
    
    func usernameAvailable(_ username: String) -> Bool{
        var usernameIsAvailable = false
        FirestoreService.shared.checkForUsernameExists(username) { (available) in
            if available {
                usernameIsAvailable = available // Username is available, this will be true.
            }
        }
        return usernameIsAvailable
    }
    
    func startLoadingAnimation() {
        self.mView.loadingAnimation.isHidden = false
        self.mView.loadingAnimation.play()
    }
    
    func stopLoadingAnimation() {
        self.mView.loadingAnimation.stop()
        self.mView.loadingAnimation.isHidden = true
    }
}
