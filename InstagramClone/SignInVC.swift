//
//  FeedViewModel.swift
//  SocialVideoApp
//
//  Created by MA1424 on 29/02/24.
//

import UIKit

class SignInViewController: UIViewController {
    
    // MARK: Properties
    
    private let viewModel = SignInViewModel()
    
    private let headerView: UIView = {
        let header = UIView()
        header.backgroundColor = .systemBlue
        return header
    }()
    
    private let titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.text = "Instagram"
        lbl.font = UIFont(name: "ChalkboardSE-Bold", size: 40)
        lbl.textColor = .white
        return lbl
    }()
    
    private let emailTF: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Email"
        tf.backgroundColor = .systemGray6
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.autocorrectionType = .no
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let passwordTF: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Password"
        tf.backgroundColor = .systemGray6
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let signInButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
        btn.setTitle("Sign In", for: .normal)
        return btn
    }()
    
    private lazy var inputFieldsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailTF, passwordTF, signInButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10.0
        return stackView
    }()
    
    private let signUpAndSignInBtn: UIButton = {
        let btn = UIButton(type: .system)
        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.systemBlue]
        let attributedString1 = NSMutableAttributedString(string:"Don’t have an account? ", attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:"Sign Up.", attributes:attrs2)
        attributedString1.append(attributedString2)
        btn.setAttributedTitle(attributedString1, for: .normal)
        btn.addTarget(self, action: #selector(didTapSignUpAndSignInButton), for: .touchUpInside)
        return btn
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureHeaderView()
        configureTitleLbl()
        configureInputFieldsStackView()
        configureaadSignUpAndSignInBtn()
        setupToHideKeyboardOnTapOnView()
        bindViewModel()
    }
    
    // MARK: Private Methods
    
    private func configureHeaderView() {
        view.addSubview(headerView)
        headerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func configureTitleLbl() {
        headerView.addSubview(titleLbl)
        titleLbl.center(inView: headerView, yConstant: 0)
    }
    
    private func configureInputFieldsStackView() {
        view.addSubview(inputFieldsStackView)
        inputFieldsStackView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 0)
    }
    
    private func configureaadSignUpAndSignInBtn() {
        self.view.addSubview(signUpAndSignInBtn)
        signUpAndSignInBtn.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom:0, paddingRight: 30, width: 0, height: 60)
    }
    
    private func bindViewModel() {
        signInButton.addTarget(self, action: #selector(handleSignInButton), for: .touchUpInside)
        viewModel.delegate = self
    }
    
    // MARK: Actions
    
    @objc private func handleSignInButton() {
        guard let email = emailTF.text, let password = passwordTF.text else { return }
        self.displayActivityIndicator(shouldDisplay: true)
        let credentials = UserCredentials(email: email, password: password)
        viewModel.signIn(with: credentials)
    }
    
    @objc private func didTapSignUpAndSignInButton() {
        // Handle sign up and sign in button tap action
        let signUpVc = RegistrationVC()
        self.navigationController?.pushViewController(signUpVc, animated: true)
    }
}

// MARK: - SignInViewModelDelegate

extension SignInViewController: SignInViewModelDelegate {
    func signInDidSucceed() {
        self.displayActivityIndicator(shouldDisplay: false)
        // Navigate to home screen or perform appropriate action
        let sceneDelegate = UIApplication.shared.connectedScenes
            .first!.delegate as! SceneDelegate
        sceneDelegate.showRootViewController()
    }
    
    func signInDidFail(with error: Error) {
        self.displayActivityIndicator(shouldDisplay: false)
        let errorMessage = error.localizedDescription
        self.presentAlertWithTitle(title: "Error", message: errorMessage, options: "OK") { (option) in }
        return
    }
}




