 //
//  NewMessageController.swift
//  MessangerFirebase
//
//  Created by Phoenix on 30.09.17.
//  Copyright © 2017 Phoenix_Dev. All rights reserved.
//

import UIKit
import Firebase
 
class NewMessageController: UITableViewController {

    let cellID = "CellId"
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "New Message"
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem = cancelButton
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        fetchUsersInfo()
    }
    
    
    func fetchUsersInfo() {
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                let user = User()
                user.id = snapshot.key
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
             }
            
            
        }, withCancel: nil)
    }

    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let profileImageURL = user.profileImageURL {
            cell.profieImageView.loadImageUseingCacheWith(urlString: profileImageURL)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    var messageViewController: MessageController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messageViewController?.showChatLogControllerFor(user: user)
        }
    }
    
 }

