//
//  LoginViewController.swift
//  MessangerFirebase
//
//  Created by Phoenix on 28.09.17.
//  Copyright © 2017 Phoenix_Dev. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.black
//        button.tintColor = UIColor(red: 62/255, green: 128/255, blue: 0/255, alpha: 1)
        button.tintColor = UIColor.white
        button.setTitle("Register", for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(loginRegisterHandler), for: .touchUpInside)
        return button
    }()
    
    let nameTextField: UITextField = {
        let field = UITextField ()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont.systemFont(ofSize: 15)
        field.placeholder = "Name"
        field.tintColor = UIColor.white
        return field
    }()
    
    let emailTextField: UITextField = {
        let field = UITextField ()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont.systemFont(ofSize: 15)
        field.placeholder = "Email"
        field.tintColor = UIColor.white
        return field
    }()
    
    let passwordTextField: UITextField = {
        let field = UITextField ()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont.systemFont(ofSize: 15)
        field.placeholder = "Password"
        field.tintColor = UIColor.white
        field.isSecureTextEntry = true
        return field
    }()
    
    lazy var avatarView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "no-image-icon-md")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = UIColor.white
        view.layer.cornerRadius = 45
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImage)))
        return view
    }()
    
    lazy var loginOrRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.black
        sc.backgroundColor = UIColor.white
        sc.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 62/255, green: 128/255, blue: 0/255, alpha: 1)], for: .normal)
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handlerLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    
    var messageController: MessageController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(red: 62/255, green: 128/255, blue: 0/255, alpha: 1)
        setupViews()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle  {
        get {
            return .lightContent
        }
    }
    
    //MARK: Configuration subviews
    var conteinerViewHeightConstraint: NSLayoutConstraint?
    var nameTextFieldHeightConstraint: NSLayoutConstraint?
    
    func setupViews() {
        
        view.addSubview(avatarView)
        view.addSubview(containerView)
        view.addSubview(registerButton)
        view.addSubview(loginOrRegisterSegmentedControl)
        containerView.addSubview(nameTextField)
        containerView.addSubview(emailTextField)
        containerView.addSubview(passwordTextField)
        
        NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: -20).isActive = true
        conteinerViewHeightConstraint = NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150)
        conteinerViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint(item: registerButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: registerButton, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 5).isActive = true
        NSLayoutConstraint(item: registerButton, attribute: .width, relatedBy: .equal, toItem: containerView, attribute: .width, multiplier: 1, constant: -100).isActive = true
        NSLayoutConstraint(item: registerButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true

        containerView.addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: nameTextField)
        containerView.addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: emailTextField)
        containerView.addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: passwordTextField)
        
        containerView.addConstraintsWithFormat(format: "V:|[v0][v1][v2]|", views: nameTextField, emailTextField, passwordTextField)
        nameTextFieldHeightConstraint = NSLayoutConstraint(item: nameTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        nameTextFieldHeightConstraint?.isActive = true
        
        NSLayoutConstraint(item: passwordTextField, attribute: .height, relatedBy: .equal, toItem: emailTextField, attribute: .height, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: loginOrRegisterSegmentedControl, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: -10).isActive = true
        view.addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: loginOrRegisterSegmentedControl)
        
        NSLayoutConstraint(item: avatarView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: avatarView, attribute: .bottom, relatedBy: .equal, toItem: loginOrRegisterSegmentedControl, attribute: .top, multiplier: 1, constant: -25).isActive = true
        NSLayoutConstraint(item: avatarView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 90).isActive = true
        NSLayoutConstraint(item: avatarView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 90).isActive = true
    }
    
    
}


extension UIView {
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        
        var viewsDictionary = [String: UIView] ()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

