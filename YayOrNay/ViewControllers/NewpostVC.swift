//
//  NewpostVC.swift
//  YayOrNay
//
//  Created by Ilay on 04/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import Lottie

class NewpostVC: UIViewController {

    let mView = NewPostView()
    let db = Firestore.firestore()

    var imageChoosen: Bool = false // Indicates if the user chose image or not.
    var imageName: String = ""
    var imagePicker: ImagePicker!
    var imageToUpload: UIImage?

    var tag: Scenario = .casual // Tag 0 is referring to the occasion type the user chose, the default is Casual.

    lazy var occasionBtns = [self.mView.casualBtn, self.mView.beachBtn, self.mView.eveningBtn, self.mView.partyBtn, self.mView.dateBtn, self.mView.workBtn]

    override func loadView() {
        super.loadView()
        self.view = mView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        mView.delegate = self
        mView.saySomethingTextview.delegate = self
        mView.postTitle.delegate = self
        
        self.navigationController?.navigationBar.tintColor = UIColor.appOrange

        imagePicker = ImagePicker(presentationController: self, delegate: self)

        let submitBtn = UIBarButtonItem(title: NSLocalizedString("submit", comment: "submit"), style: .plain, target: self, action: #selector(handleSubmit))
        navigationItem.rightBarButtonItem = submitBtn
        
        mView.imagePlaceholder.addTapGestureRecognizer { self.handleImageTap() }
        mView.postImage.addTapGestureRecognizer { self.handleImageTap() }
        mView.addTapGestureRecognizer { self.dismissKeyboard() } // Using this to dismiss the keyboard when user taps on background from uitextfield/uitextview.
    }

    private func setupNavBar(){
        let navBar = self.navigationController?.navigationBar
        navigationController?.setNavigationBarHidden(false, animated: false)
        navBar?.tintColor = UIColor.appTurquoise
        navBar?.barStyle = .default
    }
}

//MARK: Image picking
extension NewpostVC: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        if image != nil {
            self.mView.imagePlaceholder.isHidden = true
            self.mView.postImage.image = image
            self.imageChoosen = true
            self.imageToUpload = image
        }
    }
}

extension NewpostVC: NewPostViewDelegate {
    //Creating a new post, uploading it's image and uploading the post info to the database.
    @objc func handleSubmit() {
        // Only checking if the user chose an image, title is optional
        if imageChoosen {
            startLoadingAnimation()
            FirestoreService.shared.uploadImageToFirebase(imageToUpload) { (url) in
                guard let pCreatorId = UserDefaults.standard.object(forKey: USER_UID_KEY) as? String else { return }
                let pUUID = UUID().uuidString
                let pTag = self.tag
                let pTitle = self.mView.postTitle.text ?? ""
                let pBody = self.mView.saySomethingTextview.text
                guard let pUrlString = url else { return }
                
                let pUpvotes = 0
                let pDownvotes = 0
                
                let p = Post(pCreatorId, pUUID, pTag.rawValue, pTitle, pUrlString, pUpvotes, pDownvotes, pBody ?? "")
                self.uploadPost(p)
            }
        }else {
            let ac = UIAlertController(title: NSLocalizedString("upload.error.title", comment: "error"), message: NSLocalizedString("upload.error.msg", comment: "msg"), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("understand", comment: "understand"), style: .default, handler: nil))
            present(ac, animated: true)
        }
    }

    @objc func handleTagChosen(_ sender: UIButton) {
        
        self.tag = Scenario(rawValue: sender.tag) ?? Scenario(rawValue: 0)!
        
        sender.backgroundColor = .appTurquoise
        sender.setTitleColor(UIColor.appWhite, for: .normal)
        for button in occasionBtns {
            if button.tag != self.tag.rawValue {
                button.backgroundColor = UIColor.appWhiteAccent
                button.setTitleColor(UIColor.appBlack, for: .normal)
            }
        }
    }
    
    @objc func handleImageTap() {
        self.imagePicker.present(from: self.mView)
    }
    
    @objc func dismissKeyboard(){
        mView.saySomethingTextview.resignFirstResponder()
        mView.postTitle.resignFirstResponder()
    }
    
}

extension NewpostVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: Firestore functions
extension NewpostVC: UIImagePickerControllerDelegate {

    //TODO: Move this to Service.swift file
    fileprivate func uploadPost(_ post: Post){
        db.collection(POSTS_COLLECTION).document(post.postId).setData([
            POST_CREATOR: post.creatorId,
            POST_ID: post.postId,
            POST_OCCASION_TAG: post.occasionTag,
            POST_TITLE: post.postTitle,
            POST_IMAGE: post.postImage,
            POST_UPVOTES: post.postUpvotes,
            POST_DOWNVOTES: post.postDownvotes,
            POST_BODY: post.postBody ?? "",
        ]) { (err) in
            if let error = err {
                let ac = UIAlertController(title: NSLocalizedString("error", comment: "Oops"), message: err?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: NSLocalizedString("understand", comment: "I understand"), style: .default, handler: nil))
                return
            }
            self.stopLoadingAnimation()
            let vc = PostsVC()
            self.dismiss(animated: true, completion: nil)

            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .push
            transition.subtype = .fromTop
            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}

//Mark: Textview delegate
extension NewpostVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.mView.textViewPlaceholder.alpha = 0
        }, completion: nil)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.mView.textViewPlaceholder.alpha = 1
            }, completion: nil)
        }
    }
}


//Mark: Helper functions
extension NewpostVC {
    func startLoadingAnimation() {
        self.mView.loadingAnimation.isHidden = false
        self.mView.loadingAnimation.play()
    }
    
    func stopLoadingAnimation() {
        self.mView.loadingAnimation.stop()
        self.mView.loadingAnimation.isHidden = true
    }
}
