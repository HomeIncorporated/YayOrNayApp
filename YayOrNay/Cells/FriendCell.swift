//
//  FriendCell.swift
//  YayOrNay
//
//  Created by Ilay on 05/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setProfileImg()
        setFriendLabel()
        setUnfriendBtn()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isFriend: Bool = false {
        didSet {
            if isFriend == false {
                unfriendBtn.setTitle(NSLocalizedString("friend.btn", comment: "follow"), for: .normal)
                unfriendBtn.backgroundColor = .appPurple
            } else {
                unfriendBtn.setTitle(NSLocalizedString("unfriend.btn", comment: "unfollow"), for: .normal)
                unfriendBtn.backgroundColor = .appOrange
            }
        }
    }
    
    var friendId: String = ""
    
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

    let friendUsername: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "FRIEND"
        label.textColor = UIColor.appTurquoise

        return label
    }()


    let unfriendBtn: CustomUIButton = {
        let btn = CustomUIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 50).isActive = true

        btn.backgroundColor = UIColor.appOrange
        btn.setTitle(NSLocalizedString("unfriend.btn", comment: "follow"), for: .normal)
        btn.setTitleColor(UIColor.appWhite, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        btn.setBackgroundColor(UIColor.appWhite, for: .highlighted)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true

        btn.layer.cornerRadius = 10

        return btn
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    //MARK: Set profile img
    fileprivate func setProfileImg(){
        addSubview(profileImg)
        NSLayoutConstraint.activate([
            profileImg.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            profileImg.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }

    //MARK: Set friend label
    fileprivate func setFriendLabel(){
        addSubview(friendUsername)
        NSLayoutConstraint.activate([
            friendUsername.leadingAnchor.constraint(equalTo: profileImg.trailingAnchor, constant: 5),
            friendUsername.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }

    //MARK: Set unfriend btn
    fileprivate func setUnfriendBtn(){
        addSubview(unfriendBtn)
        NSLayoutConstraint.activate([
            unfriendBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            unfriendBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            unfriendBtn.heightAnchor.constraint(equalToConstant: 20),
            unfriendBtn.widthAnchor.constraint(equalToConstant: 45),
        ])
    }
}
