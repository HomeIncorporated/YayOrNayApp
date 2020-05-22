//
//  ShowFriends.swift
//  YayOrNay
//
//  Created by Ilay on 23/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit
import FirebaseAuth

private let friendCell = "FriendCell"

class ShowFriends: NSObject, UITableViewDataSource, UITableViewDelegate {

    lazy var searchBar = self.friendsTable.tableHeaderView?.subviews[0] as?  UISearchBar
    
    // Instead of using FRIENDS_LIST itself, we are assigning it to fetchedFriends, so we can manipulate the list (when searching user for example) without modifying FRIENDS_LIST
    private var fetchedFriends: [Friend]!
    
    private let dimView = UIView()
    private var isSearchedFlag: Bool = false // flag variable to check if we did or didn't perform a search, we will use this to only use isAlreadyAFriend in the cell setup function when it is true.
    
    
    private let friendsTable: UITableView = {
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.allowsSelection = true
        table.layer.cornerRadius = 15
        table.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        table.separatorInset.right = table.separatorInset.left
        
        let tableHeader: UIView = UIView.init(frame: CGRect.init(x: 1, y: 50, width: UIScreen.main.bounds.width, height: 40))
        
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 0, height: 25))
        searchBar.barStyle = .default
        searchBar.placeholder = NSLocalizedString("searchbar.placeholder", comment: "find")
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: UIBarMetrics.default) // Using this to get rid of the rectangle border of the searchBar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        tableHeader.addSubview(searchBar)

        searchBar.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        searchBar.widthAnchor.constraint(equalToConstant: tableHeader.frame.width - 16).isActive = true
        searchBar.topAnchor.constraint(equalTo: tableHeader.topAnchor, constant: 0).isActive = true
        
        table.tableHeaderView = tableHeader

        return table
    }()

    func showFriends(){
        if let window = UIApplication.shared.keyWindow {
                    
            self.fetchedFriends = FRIENDS_LIST
            displayFriendsOnList()
            
            dimView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            window.addSubview(dimView)
            window.addSubview(friendsTable)

            let height = window.frame.height - 80
            let y = window.frame.height - height // This is so we can later slide friendsTable all the way down.

            friendsTable.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)

            dimView.frame = window.frame
            dimView.alpha = 0

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

                self.dimView.alpha = 1
                self.friendsTable.frame = CGRect(x: 0, y: y, width: self.friendsTable.frame.width, height: self.friendsTable.frame.height)
            })
        }
    }

    @objc func handleDismiss(){
        UIView.animate(withDuration: 0.5) {
            self.dimView.alpha = 0
            if let window = UIApplication.shared.keyWindow  {
                self.friendsTable.frame = CGRect(x: 0, y: window.frame.height, width: self.friendsTable.frame.width, height: self.friendsTable.frame.height)
            }
        }
        
        dismissSearchBar(searchBar!)
    }

    override init() {
        super.init()
        
        searchBar?.delegate = self
        
        let panGesture = PanDirectionGestureRecognizer(direction: .vertical(.down), target: self, action: #selector(panGestureRecognizerHandler(_:)))
        
        friendsTable.delegate = self
        friendsTable.dataSource = self

        friendsTable.register(FriendCell.self, forCellReuseIdentifier: friendCell)

        friendsTable.tableHeaderView?.addGestureRecognizer(panGesture)
        
        friendsTable.addTapGestureRecognizer { self.dismissSearchBar(self.searchBar!) }
        
    }
}

extension ShowFriends {
    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: friendsTable.window)
        var initialTouchPoint = CGPoint.zero

        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            if touchPoint.y > initialTouchPoint.y {
                friendsTable.frame.origin.y = initialTouchPoint.y + touchPoint.y
            }
        case .ended, .cancelled:
            if touchPoint.y - initialTouchPoint.y > 300 {
                handleDismiss()
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

                    if let window = UIApplication.shared.keyWindow {
                        let height = window.frame.height - 80
                        let y = window.frame.height - height
                        
                        self.dimView.alpha = 1
                        self.friendsTable.frame = CGRect(x: 0, y: y, width: self.friendsTable.frame.width, height: self.friendsTable.frame.height)
                    }
                })
            }
        case .failed, .possible:
            break
        default:
            break
        }
    }
}

//MARK: Helper function & Handlers
extension ShowFriends {
    
    func displayFriendsOnList() {
        self.friendsTable.reloadData()
    }
    
    @objc func handleFollow(_ sender: CustomUIButton) {
        FirestoreService.shared.isAlreadyAFriend(sender.extraStringInfo) { (isAFriend) in
            if isAFriend {
                Friend.removeFriendFromList(sender.extraStringInfo) { (removed) in
                    if removed {
                        self.fetchedFriends = FRIENDS_LIST
                        self.friendsTable.reloadData()
                    }
                }
            }else {
                Friend.addFriendToList(sender.extraStringInfo) { (added) in
                    if added {
                        self.searchBar?.text = ""
                        self.searchBar?.resignFirstResponder()
                        self.fetchedFriends = FRIENDS_LIST
                        self.friendsTable.reloadData()
                    }
                }
            }
        }
    }
}

//MARK: Tableview functions
extension ShowFriends {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedFriends.count
    }

    //We DO NOT need to check if the user is a friend here, the list is showing all the friends already.
    //We Do check if the user found after search is a friend or not, because it may not be a friend, so we should have an option to add it.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: friendCell, for: indexPath) as! FriendCell
        cell.selectionStyle = .none
        
        if fetchedFriends.count > 0 {
            let friend = fetchedFriends[indexPath.row]
            
            cell.friendUsername.text = friend.username
            cell.profileImg.loadImageUsingCacheWithUrlString(urlString: friend.profilePicture)
            
            cell.unfriendBtn.extraStringInfo = friend.id // CustomUIButton, extraStringInfo is used to send the user's id to the handleFollow function.
            
            cell.unfriendBtn.addTarget(self, action: #selector(handleFollow(_:)), for: .touchUpInside)
            //If what we see on the table view is search items.
            //After searching, we will check if the User we are seeing on the tableView is a friend or not, and change the button ui accordingly (button ui changes in FriendCell.swift)
            if isSearchedFlag {
                FirestoreService.shared.isAlreadyAFriend(friend.id) { (isAlreadyAFriend) in
                    if isAlreadyAFriend {
                        cell.isFriend = true
                    }else {
                        cell.isFriend = false
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userId = fetchedFriends[indexPath.row].id
        let userName = fetchedFriends[indexPath.row].username
        
        FirestoreService.shared.fetchPostsByUser(user: userId) { (fetchedPosts) in
            if fetchedPosts != nil {
                POSTS_BY_USER = fetchedPosts
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "postsByUserChosen"), object: fetchedPosts, userInfo: ["byUser": userName])
                self.handleDismiss()
            }
        }
    }
}

extension ShowFriends: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text?.lowercased() else { return } // Possibly the user's name we want to search.
        DispatchQueue.global(qos: .userInitiated).async {
            FirestoreService.shared.searchForUser(user: searchTerm) { (user) in
                if user != nil {
                    self.fetchedFriends = []
                    self.fetchedFriends.append(user!) // force unwrap because we already checked the user we got is not nil.
                    self.friendsTable.reloadData()
                    self.isSearchedFlag = true
                }else {
                    return
                }
            }
        }
        searchBar.resignFirstResponder()
    }
    
    @objc func dismissSearchBar(_ searchBar: UISearchBar){
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    
}
