//
//  ViewController.swift
//  MessangerFirebase
//
//  Created by Phoenix on 28.09.17.
//  Copyright © 2017 Phoenix_Dev. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {

    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handlerLogout))
        
        let image = UIImage(named: "new_message1600")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        checkIfUserLogin()
//        observeMessages()
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
    
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in

            let userID = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userID).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                
                let messageRef = Database.database().reference().child("messages").child(messageId)
                messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dict = snapshot.value as? [String: Any] {
                        let message = Message(dictionary: dict)
                        
                        if let chatPatnerId = message.chatPartnerID() {
                            self.messagesDictionary[chatPatnerId] = message
                        }
                        
                        self.timer?.invalidate()
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateTableView), userInfo: nil, repeats: false)
                    }
                    
                    
                }, withCancel: nil)
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    var timer: Timer?
    
    func updateTableView() {
        
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    func checkIfUserLogin() {
        //  перевіряємо чи користувач увійшов в систему
        if Auth.auth().currentUser?.uid == nil {
            // якщо жоден користувач не ввішов відображаємо вікно автоизації
            perform(#selector(handlerLogout), with: nil, afterDelay: 0)
        } else {
            // якщо корисутвач в системі отримуємо його дані з firebase
                fetchUserAndUpdateNavBarTitle()
        }
    }
    
    
    func fetchUserAndUpdateNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Database.database().reference().child("Users").child(uid).observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
//                self.navigationItem.title = dictionary["name"] as? String
                
                let user = User()
                
                user.setValuesForKeys(dictionary)
                self.setupNavigationBarWith(user: user)
            }
            
            
        }, withCancel: nil)

    }
    
    
    func setupNavigationBarWith(user: User) {
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
//        titleView.backgroundColor = UIColor.red
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        
        if let profileImageUrl = user.profileImageURL {
            profileImageView.loadImageUseingCacheWith(urlString: profileImageUrl)
        }
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.textColor = UIColor.white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        containerView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        
        // config constraint
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatLogController)))
    }
    
    
    func showChatLogControllerFor(user: User) {
        let chatLogVC = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogVC.user = user
        navigationController?.pushViewController(chatLogVC, animated: true)
    }
    
    func handleNewMessage() {
        let newMessageVC = NewMessageController()
        newMessageVC.messageViewController = self
        let navVC = UINavigationController(rootViewController: newMessageVC)
        present(navVC, animated: true, completion: nil)
    }
    
    func handlerLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginVC = LoginViewController()
        loginVC.messageController = self
        present(loginVC, animated: true, completion: nil)
    }

    
    //MARK: - UI table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerID = message.chatPartnerID() else {return}
        let ref = Database.database().reference().child("Users").child(chatPartnerID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String: Any] else {return}
            
            let user = User()
            user.id = chatPartnerID
            user.setValuesForKeys(dict)
            
            self.showChatLogControllerFor(user: user)
            
        }, withCancel: nil)
        
        
    }
}

