//
//  ChatMessageCell.swift
//  MessangerFirebase
//
//  Created by Phoenix on 02.10.17.
//  Copyright © 2017 Phoenix_Dev. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    var chatLogController: ChatLogController?

    var message: Message?
    
    let textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "bla bla bla"
        view.font = UIFont.systemFont(ofSize: 15)
        view.isEditable = false
        view.autocapitalizationType = .words
//        view.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        view.textColor = UIColor.white
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    let bubleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 62/255, green: 128/255, blue: 0/255, alpha: 1)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "no-image-icon-md")
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var messageImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomImage(tapGesture:))))
        return view
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "play_button"), for: .normal)
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    
    func handleZoomImage(tapGesture: UITapGestureRecognizer) {
        
        if let imageView = tapGesture.view as? UIImageView {
            chatLogController?.performZoomInForStartingImageView(imageView)
        }
    }
    
    var playerlayer: AVPlayerLayer?
    var player:AVPlayer?
    
    func handlePlay() {
    
        if let urlString = message?.videoURL, let url = URL(string: urlString) {
            
            player = AVPlayer(url: url)
            playerlayer = AVPlayerLayer(player: player)
            playerlayer?.frame = bubleView.bounds
            bubleView.layer.addSublayer(playerlayer!)
            
            player?.play()
            
            activityIndicator.startAnimating()
            playButton.isHidden = true
        }
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerlayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicator.stopAnimating()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setupViews()
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var bubleWidthAnchor: NSLayoutConstraint?
    var bubleRightAnchor: NSLayoutConstraint?
    var bubleLeftAnchor: NSLayoutConstraint?
    
    func setupViews() {
        addSubview(bubleView)
        addSubview(textView)
        addSubview(profileImage)
        
        bubleView.addSubview(messageImageView)
        messageImageView.leftAnchor.constraint(equalTo: bubleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubleView.heightAnchor).isActive = true
        
        bubleRightAnchor = bubleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubleLeftAnchor = bubleView.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 8)
        
        bubleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        bubleWidthAnchor = bubleView.widthAnchor.constraint(equalToConstant: 200)
        bubleWidthAnchor?.isActive = true
        
        bubleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        textView.leftAnchor.constraint(equalTo: bubleView.leftAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubleView.rightAnchor, constant: -8).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        profileImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        
        bubleView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: bubleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubleView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: bubleView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: bubleView.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
}
