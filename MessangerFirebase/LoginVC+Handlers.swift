//
//  LoginVC+Handlers.swift
//  MessangerFirebase
//
//  Created by Phoenix on 01.10.17.
//  Copyright © 2017 Phoenix_Dev. All rights reserved.
//

import UIKit
import Firebase

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleSelectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromImagePicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromImagePicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromImagePicker = originalImage
            
        }
        
        if let selectedImge = selectedImageFromImagePicker {
            avatarView.image = selectedImge
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Action
    
    func loginRegisterHandler() {
        if loginOrRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [unowned self](user, error) in
            if error != nil {
                print(error!)
                return
            }
            
            // success login
            self.messageController?.fetchUserAndUpdateNavBarTitle()
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            
            // success authorization
            guard let uid = user?.uid else {return}
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.avatarView.image ,let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error2) in
                    if error2 != nil {
                        print(error2!)
                        return
                    }

                    if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                        let values = ["name": name, "email": email, "profileImageURL": profileImageURL]
                        
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values)
                    }
                })
            }
        }
    }
    
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any]) {
        
        let ref = Database.database().reference()
        let usersRef = ref.child("Users").child(uid)
        usersRef.updateChildValues(values, withCompletionBlock: { [unowned self] (err, reference) in
            
            if err != nil {
                print(err!)
                return
            }
            
            self.messageController?.fetchUserAndUpdateNavBarTitle()
            self.dismiss(animated: true, completion: nil)
            print("Success save ures info in firebase")
        })

    }
    
    func handlerLoginRegisterChange() {
        let title = loginOrRegisterSegmentedControl.titleForSegment(at: loginOrRegisterSegmentedControl.selectedSegmentIndex)
        registerButton.setTitle(title, for: .normal)
        
        if loginOrRegisterSegmentedControl.selectedSegmentIndex == 0 {
            conteinerViewHeightConstraint?.constant = 100
            nameTextFieldHeightConstraint?.constant = 0
            nameTextField.isHidden = true
        } else {
            conteinerViewHeightConstraint?.constant = 150
            nameTextFieldHeightConstraint?.constant = 50
            nameTextField.isHidden = false
        }
    }

}

