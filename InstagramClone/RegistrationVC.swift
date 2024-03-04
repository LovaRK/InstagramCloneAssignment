//
//  FeedViewModel.swift
//  SocialVideoApp
//
//  Created by MA1424 on 29/02/24.
//

import UIKit

class RegistrationVC: UIViewController {
    
    var viewModel = RegistrationViewModel()
    var imagePicker: ImagePicker!
    
    let signUpAndSignInBtn: UIButton = {
        let btn = UIButton(type: .system)
        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.systemBlue]
        let attributedString1 = NSMutableAttributedString(string:"Already have an account? ", attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:"Sign In", attributes:attrs2)
        attributedString1.append(attributedString2)
        btn.setAttributedTitle(attributedString1, for: .normal)
        btn.addTarget(self, action: #selector(didTapSignInButton), for: .touchUpInside)
        return btn
    }()
    
    let addImageButton: UIButton = {
        let btn                     = UIButton()
        let homeSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 100, weight: .black)
        let homeImage               = UIImage(systemName: "person.crop.circle.badge.plus", withConfiguration: homeSymbolConfiguration)
        let width                   = homeImage?.size.width
        let height                  = homeImage?.size.height
        btn.setImage(homeImage, for: .normal)
        btn.addTarget(self, action: #selector(didTapAddImageButton), for: .touchUpInside)
        return btn
    }()
    
    let signUpButton: UIButton = {
        let btn                     = UIButton()
        btn.backgroundColor         = UIColor.systemBlue
        btn.layer.cornerRadius      = 5
        btn.clipsToBounds           = true
        btn.setTitle("Sign Up", for: .normal)
        btn.addTarget(self, action: #selector(handleSignUpButton), for: .touchUpInside)
        return btn
    }()
    
    let emailTF: UITextField = {
        let tf = UITextField()
        tf.placeholder        = "Enter Email"
        tf.backgroundColor    = UIColor.systemGray6
        tf.borderStyle        = .roundedRect
        tf.font               = UIFont.systemFont(ofSize: 16)
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.keyboardType       = .emailAddress
        return tf
    }()
    
    let passwordTF: UITextField = {
        let tf = UITextField()
        tf.placeholder       = "Enter Password"
        tf.backgroundColor   = UIColor.systemGray6
        tf.borderStyle       = .roundedRect
        tf.font              = UIFont.systemFont(ofSize: 16)
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let userNameTF: UITextField = {
        let tf = UITextField()
        tf.placeholder     = "Enter User Name"
        tf.backgroundColor = UIColor.systemGray6
        tf.borderStyle     = .roundedRect
        tf.font            = UIFont.systemFont(ofSize: 16)
        return tf
    }()
    
    //Stack View
    let inPutFieldsStackView: UIStackView = {
        let stackView           = UIStackView()
        stackView.axis          = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fillEqually
        stackView.alignment     = UIStackView.Alignment.fill
        stackView.spacing       = 10.0
        return stackView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupUI() {
        setUpNavigationBar()
        configureadImageButton()
        configureInPutFieldsStackView()
        configureaadSignUpAndSignInBtn()
        setupToHideKeyboardOnTapOnView()
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        viewModel.delegate = self
        viewModel.imagePickerDelegate = self
    }
    
    func setUpNavigationBar() {
        view.backgroundColor = UIColor.white
        title = "Sign Up"
    }
    
    func configureadImageButton() {
        view.addSubview(addImageButton)
        addImageButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        NSLayoutConstraint.activate([
            addImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func configureInPutFieldsStackView() {
        inPutFieldsStackView.addArrangedSubview(emailTF)
        inPutFieldsStackView.addArrangedSubview(userNameTF)
        inPutFieldsStackView.addArrangedSubview(passwordTF)
        inPutFieldsStackView.addArrangedSubview(signUpButton)
        view.addSubview(inPutFieldsStackView)
        inPutFieldsStackView.anchor(top: addImageButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 200)
    }
    
    func configureaadSignUpAndSignInBtn() {
        view.addSubview(signUpAndSignInBtn)
        signUpAndSignInBtn.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom:0, paddingRight: 30, width: 0, height: 60)
    }
    
    @objc func didTapSignInButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapAddImageButton() {
        imagePicker.present(from: view)
    }
    
    
    @objc private func handleSignUpButton() {
        self.displayActivityIndicator(shouldDisplay: true)

        viewModel.email = emailTF.text ?? ""
        viewModel.password = passwordTF.text ?? ""
        viewModel.userName = userNameTF.text ?? ""
        viewModel.signUp()
    }
}

extension RegistrationVC: ImagePickerDelegate {
    func didSelect(videoURL: URL?) {
        
    }
    
    func didSelect(image: UIImage?) {
        // Update the profileImage property of the view model
        viewModel.profileImage = image
        
        addImageButton.layer.cornerRadius = addImageButton.frame.width / 2
        addImageButton.clipsToBounds = true
        addImageButton.layer.borderWidth = 1.5
        addImageButton.layer.borderColor = UIColor.black.cgColor
        addImageButton.setImage(image, for: .normal)
        addImageButton.imageView?.contentMode = .scaleAspectFill
    }
}

extension RegistrationVC: RegistrationViewModelDelegate {
    func signUpDidSucceed() {
        self.displayActivityIndicator(shouldDisplay: false)

        let sceneDelegate = UIApplication.shared.connectedScenes
            .first!.delegate as! SceneDelegate
        sceneDelegate.showRootViewController()
    }
    
    func signUpDidFail(with errorMessage: String) {
        self.displayActivityIndicator(shouldDisplay: false)

        presentAlertWithTitle(title: "Error", message: errorMessage, options: "Ok") { option in
            print("option: \(option)")
        }
    }
}



