//
//  UserCell.swift
//  MessangerFirebase
//
//  Created by Phoenix on 02.10.17.
//  Copyright © 2017 Phoenix_Dev. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            
            setupNameAndProfileImage()
            
            detailTextLabel?.text = message? .text
            
            let date = Date(timeIntervalSince1970: (message?.timestamp?.doubleValue)!)
            let dateFormatter = DateFormatter()
            dateFormatter .dateFormat = "HH:mm:ss"
            timeLabel.text = dateFormatter.string(from: date)
        }
    }
    
    
    private func setupNameAndProfileImage() {
        
                
        if let id = message?.chatPartnerID()  {
            let ref = Database.database().reference().child("Users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: Any] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageURL = dictionary["profileImageURL"] as? String {
                        self.profieImageView.loadImageUseingCacheWith(urlString: profileImageURL)
                    }
                }
                
            }, withCancel: nil)
        }
    }
    
    
    let profieImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "no-image-icon-md")
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        return view
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "hh:mm:ss"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        label.textAlignment = .right
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 76, y: (textLabel?.frame.origin.y)! - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 76, y: (detailTextLabel?.frame.origin.y)! + 2, width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profieImageView)
        addSubview(timeLabel)
        
        profieImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profieImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profieImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profieImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

