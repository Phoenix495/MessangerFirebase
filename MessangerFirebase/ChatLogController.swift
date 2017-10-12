//
//  ChatLogController.swift
//  MessangerFirebase
//
//  Created by Phoenix on 02.10.17.
//  Copyright © 2017 Phoenix_Dev. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cellID = "cellID"
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    lazy var inputTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.attributedPlaceholder = NSAttributedString(string: "Enter your message...", attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.5), NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
        field.textColor = UIColor.white
        field.delegate = self
        return field
    }()
    
    
    lazy var inputContainerView: UIView = {
        
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor(red: 62/255, green: 128/255, blue: 0/255, alpha: 1)
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "Clip")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        
        containerView.addSubview(uploadImageView)
        uploadImageView.leftAnchor.constraint(equalTo:  containerView.leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 21.5).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.tintColor = UIColor.white
        sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        containerView.addSubview(self.inputTextField)
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 2).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        navigationItem.title = "Chat"
        collectionView?.backgroundColor = UIColor.white
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(8, 0,  8, 0)
        
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        
        setupKeyboardObserver()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    func  setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }

    
    func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    
    func observeMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid, let toID = user?.id else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toID)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageID = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageID)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dict = snapshot.value as? [String: Any] else {return}
                
                self.messages.append(Message(dictionary: dict))
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    
                    // set scrolling collection view to last message
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
    
    func handleSendMessage() {
        
        let properties = ["text": inputTextField.text!] as [String : Any]
        sendMessageWithProperties(properties)
        
    }
    
    
    func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }

    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            
            // selected video
            handleSelectVideoWithUrl(videoURL)
            
        } else {
            
            // selected image
            handleSelectImageWithInfo(info)
            
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    private func handleSelectVideoWithUrl(_ videoUrl: URL) {
        let filename = NSUUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("message_videos").child(filename).putFile(from: videoUrl, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("Failed to upload video:", error!)
                return
            }
            
            if let storageURL = metadata?.downloadURL()?.absoluteString {
                print(storageURL)
                
                if let thumbnailImage = self.thumbnailImageForURL(videoUrl) {
                 
                    self.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageURL) in
                    
                        let properties: [String: Any] = ["imageURL": imageURL, "imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height, "videoURL": storageURL]
                        self.sendMessageWithProperties(properties)
                    })
                    
                }
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    
    private func thumbnailImageForURL(_ videoUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
        
            let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: cgImage)

        } catch let err {
            print(err)
        }
        
        return nil
    }
    
    private func handleSelectImageWithInfo(_ info: [String: Any]) {
        var selectedImageFromImagePicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromImagePicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromImagePicker = originalImage
            
        }
        
        if let selectedImage = selectedImageFromImagePicker {
//            uploadToFirebaseStorageUsingImage(selectedImge)
            
            uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageURL) in
                let properties: [String: Any] = ["imageURL": imageURL, "imageWidth": selectedImage.size.width, "imageHeight": selectedImage.size.height]
                self.sendMessageWithProperties(properties)
            })
        }

    }
    
    
    private func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageURL: String) -> ()) {
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("messages_image").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Failed to upload image: ", error!)
                    return
                }
                
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    completion(imageURL)
                }
            })
        }
    }
    
    
    private func sendMessageWithProperties(_ properties: [String: Any]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = user?.id
        let fromId = Auth.auth().currentUser?.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var values = ["toId" : toId!, "fromId" : fromId!, "timestamp" : timestamp] as [String : Any]
        
        // append properties onto values
        // key $0, value $1
        properties.forEach({(values[$0] = $1)})
        
        childRef.updateChildValues(values) { (error, reference) in
            if error != nil {
                print(error!)
                return
            }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId!).child(toId!)
            let messageID = childRef.key
            userMessagesRef.updateChildValues([messageID: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId!).child(fromId!)
            recipientUserMessagesRef.updateChildValues([messageID: 1])
            
            self.inputTextField.text = nil
        }
    }
    
    //MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        
        cell.textView.text = message.text
        
        cell.chatLogController = self
        cell.message = message
        
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubleWidthAnchor?.constant = estimatedFrameFor(text: text).width + 32
        } else if message.imageURL != nil {
            cell.bubleWidthAnchor?.constant = 200
        }
        
        cell.playButton.isHidden = message.videoURL == nil
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.resignFirstResponder()
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        
        if let profImageURL = user?.profileImageURL {
            cell.profileImage.loadImageUseingCacheWith(urlString: profImageURL)
        }
        
        // detect who send message
        
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubleView.backgroundColor = UIColor(red: 62/255, green: 128/255, blue: 0/255, alpha: 1)
            cell.textView.textColor = UIColor.white
            cell.bubleRightAnchor?.isActive = true
            cell.bubleLeftAnchor?.isActive = false
            cell.profileImage.isHidden = true
            
        } else {
            cell.bubleView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            cell.textView.textColor = UIColor.black
            
            cell.bubleRightAnchor?.isActive = false
            cell.bubleLeftAnchor?.isActive = true
            cell.profileImage.isHidden = false
        }
        
        if let messageImageUrl = message.imageURL {
            cell.messageImageView.loadImageUseingCacheWith(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.textView.isHidden = true
            cell.bubleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
            cell.textView.isHidden = false
        }

    }
    
    
    //MARK: - Flow layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        
        if let text = message.text {
            height = estimatedFrameFor(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            // h1 / w1 = h2 / w2
            // solve for h1
            // h1 = h2 / w2 * w1
            
            height = CGFloat(imageHeight / imageWidth * 200)
            
        }
        
        return CGSize(width: UIScreen.main.bounds.size.width, height: height)
        
    }
    
    private func estimatedFrameFor(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)], context: nil)
    }
    
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    // perform zooming image logic
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {

        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.convert(startingImageView.frame, to: nil)
        let zoomingImagrView = UIImageView(frame: startingFrame!)
        zoomingImagrView.backgroundColor = UIColor.red
        zoomingImagrView.image = startingImageView.image
        zoomingImagrView.isUserInteractionEnabled = true
        zoomingImagrView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImagrView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 0.9
                self.inputContainerView.alpha = 0
                
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                
                zoomingImagrView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height:height)
                zoomingImagrView.center = keyWindow.center
                
            }, completion: nil)
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {

        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1

            }, completion: { (completed) in
                
                zoomOutImageView.removeFromSuperview()
                self.blackBackgroundView?.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
}
