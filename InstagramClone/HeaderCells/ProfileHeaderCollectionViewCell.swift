//
//  FeedViewModel.swift
//  SocialVideoApp
//
//  Created by MA1424 on 29/02/24.
//

import UIKit

protocol ProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
    func shareProfile()
}

class ProfileHeaderCollectionViewCell: UICollectionViewCell {
    
    var delegate: ProfileHeaderDelegate?
    
    var user: UserProfile? {
        didSet{
            guard let profileUrl = user?.profilePictureUrl  else { return }
            profile.loadImageUsingCache(withUrl: profileUrl, placeholder: UIImage(named: "placeholder"))
            usernameLabel.text = user?.username
            self.configureStatus(post: user?.posts.count ?? 0, followers: 0, following: 0)
        }
    }
    
    let profile: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.backgroundColor = UIColor.lightGray.withAlphaComponent(0.40)
        image.image = UIImage(named: "placeholder")
        return image
    }()
    
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.tintColor = UIColor.systemBlue
        button.addTarget(self, action: #selector(toogleGridView), for: .touchUpInside)
        return button
    }()
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor.systemGray3
        button.addTarget(self, action: #selector(toogleLitsView), for: .touchUpInside)
        return button
    }()
    
    lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton])
        stackView.axis          = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.fillEqually
        stackView.alignment     = UIStackView.Alignment.fill
        return stackView
    }()
    
    lazy var statsviewStackView: UIStackView = {
       let stackView = UIStackView.init(arrangedSubviews: [postLabel, followersabel, followingLabel])
        stackView.distribution = .fillEqually
        stackView.axis         = .horizontal
        return stackView
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.clipsToBounds = true
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 3.0
        button.layer.borderColor = UIColor.black.cgColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
       // button.addTarget(self, action: #selector(editOrFollow), for: .touchUpInside)
        return button
    }()
    
    lazy var postLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    lazy var followersabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var topDividerView: UIView = {
        let view  = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    lazy var bottomDividerView: UIView = {
        let view  = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    // View Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.configureadProfileImage()
        self.configureadBottomStackView()
        self.configuredNameLbl()
        self.configuredStatsview()
        self.configuredShareButn()
        self.configureStatus(post: 0, followers: 0, following: 0)
    }
    
    func  configureadProfileImage() {
        self.addSubview(profile)
        self.profile.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 100 , height: 100)
        self.profile.layer.cornerRadius = 50
    }
    
    func configureadBottomStackView() {
        self.addSubview(buttonsStackView)
        self.addSubview(topDividerView)
        self.addSubview(bottomDividerView)
        buttonsStackView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 2, paddingRight: 0, width: 0, height: 50)
        topDividerView.anchor(top: buttonsStackView.topAnchor, left: buttonsStackView.leftAnchor, bottom: nil, right: buttonsStackView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1.5)
        bottomDividerView.anchor(top: nil, left: buttonsStackView.leftAnchor, bottom: buttonsStackView.bottomAnchor, right: buttonsStackView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1.5)
    }
    
    func configuredNameLbl() {
        self.addSubview(usernameLabel)
        self.usernameLabel.anchor(top: profile.bottomAnchor, left: profile.leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
    func configuredStatsview() {
        self.addSubview(statsviewStackView)
        statsviewStackView.anchor(top: topAnchor, left: profile.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 10, width: 0, height: 50)
    }
    
    func configuredShareButn() {
        self.addSubview(shareButton)
        shareButton.anchor(top: statsviewStackView.bottomAnchor, left: statsviewStackView.leftAnchor, bottom: nil, right: statsviewStackView.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
    }
    
    func configureStatus(post: Int, followers: Int, following: Int) {
        // post label
        let postsAttributedText = NSMutableAttributedString(string: String(post) + "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        postsAttributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        postLabel.attributedText = postsAttributedText
        // followersabel
        let followersAttributedText = NSMutableAttributedString(string: String(followers) + "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        followersAttributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        followersabel.attributedText = followersAttributedText
        //followingLabel
        let followingAttributedText = NSMutableAttributedString(string: String(following) + "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        followingAttributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        followingLabel.attributedText = followingAttributedText
    }
    
    @objc func toogleLitsView() {
        resetTints()
        listButton.tintColor = UIColor.systemBlue
        delegate?.didChangeToListView()
    }
    
    @objc func toogleGridView() {
        resetTints()
        gridButton.tintColor = UIColor.systemBlue
        delegate?.didChangeToGridView()
    }
    
    fileprivate func resetTints() {
        gridButton.tintColor = UIColor.systemGray3
        listButton.tintColor = UIColor.systemGray3
    }
    
}
