//
//  FeedViewModel.swift
//  SocialVideoApp
//
//  Created by MA1424 on 29/02/24.
//

import UIKit
import AVKit

protocol HomeCollectionViewCellDelegate: AnyObject {
    func didTapLikeButton(at indexPath: IndexPath)
}


class HomeCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    var viewModel: PostViewModel? {
        didSet {
            populateCell()
        }
    }
    
    var stackHeight: NSLayoutConstraint?
    
    let cellID = "HomeCellPhotoCell"
    
    weak var delegate: HomeCollectionViewCellDelegate?
    var indexPath: IndexPath?
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    let profileImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    let profileName: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        return lbl
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(likePost), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(showComments), for: .touchUpInside)
        return button
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(sharePost), for: .touchUpInside)
        return button
    }()
    
    lazy var bookMarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(bookmarkPost), for: .touchUpInside)
        return button
    }()
    
    lazy var postDescriptionLbl: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        return lbl
    }()
    
    lazy var dateLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = .darkGray
        return lbl
    }()
    
    lazy var page: UIPageControl = {
        let page = UIPageControl()
        page.currentPageIndicatorTintColor = .systemBlue
        page.pageIndicatorTintColor = .lightGray.withAlphaComponent(0.57)
        page.hidesForSinglePage = true
        return page
    }()
    
    lazy var imageViewCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(NewPostCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        let playImage = UIImage(systemName: "play.circle.fill") // SF Symbol for play button
        button.setImage(playImage, for: .normal)
        button.tintColor = .white // Adjust the color of the play button as needed
        
        // Set content mode for the button's image
        button.imageView?.contentMode = .scaleAspectFill
        
        // Set the size of the button
        let buttonSize: CGFloat = 100 // Adjust the size as needed
        button.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        
        button.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [likeButton, commentButton, shareButton])
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var pageStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [page])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup Methods
    func setup() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        profileImageView.clipsToBounds = true
        
        addSubview(profileName)
        profileName.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 10, paddingBottom: 0, paddingRight: 8, width: 0, height: 40)
        
        addSubview(imageView)
        imageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(imageViewCV)
        imageViewCV.anchor(top: imageView.topAnchor, left: imageView.leftAnchor, bottom: imageView.bottomAnchor, right: imageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.setupPageControll()
        addSubview(buttonsStack)
        buttonsStack.anchor(top: pageStack.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 50)
        addSubview(bookMarkButton)
        bookMarkButton.anchor(top: imageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 40, height: 50)
        addSubview(postDescriptionLbl)
        postDescriptionLbl.anchor(top: buttonsStack.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
        addSubview(dateLbl)
        dateLbl.anchor(top: postDescriptionLbl.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 20)
        
        addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        
    }
    
    fileprivate func setupPageControll() {
        addSubview(pageStack)
        pageStack.anchor(top: imageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 10)
        pageStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 0).isActive = true
        stackHeight = pageStack.heightAnchor.constraint(equalToConstant: 10)
        stackHeight?.isActive = true
        centerX(inView: pageStack)
    }
    
    private func populateCell() {
        guard let viewModel = viewModel else { return }
        
        profileName.text = viewModel.profileNameText
        postDescriptionLbl.attributedText = viewModel.postDescriptionText
        dateLbl.text = viewModel.dateText
        page.numberOfPages = viewModel.numberOfPages
        
        profileImageView.image = nil // Reset image to avoid reuse issues
        
        // Update like button
        if let isLiked = viewModel.isPostLiked {
                updateLikeButton(isLiked: isLiked)
            }
        
        if let url = viewModel.profileImageUrl {
            // Load profile image
            profileImageView.loadImageUsingCache(withUrl: url.absoluteString, placeholder: UIImage(named: "placeholder"))
        }
        
        if viewModel.isVideo {
            // Load video thumbnail image
            if let thumbnailUrl = viewModel.thumbnailUrl {
                   imageView.loadImageUsingCache(withUrl: thumbnailUrl, placeholder: UIImage(named: "placeholder"))
               }
               imageView.tintColor = .white // Adjust play button color
               playButton.isHidden = false // Show play button for video
        } else {
            // Load main image
            if let imageUrl = viewModel.imageUrl(at: 0) { // Assuming the first image is the main one
                imageView.loadImageUsingCache(withUrl: imageUrl.absoluteString, placeholder: UIImage(named: "placeholder"))
            }
            playButton.isHidden = true // Hide play button for non-video
        }
        
        imageViewCV.reloadData() // Reload to display additional images
    }

    
    // MARK: Actions
    @objc func likePost() {
        // Implement like functionality
        guard let indexPath = indexPath else {
            print("indexPath is nil")
            return
        }
        delegate?.didTapLikeButton(at: indexPath)
    }
    
    @objc func showComments() {
        // Implement show comments functionality
    }
    
    @objc func sharePost() {
        // Implement share functionality
    }
    
    @objc func bookmarkPost() {
        // Implement bookmark functionality
    }
    
    @objc func playVideo() {
        guard let viewModel = viewModel else {
            return
        }
        
        if viewModel.isVideo, let videoUrl = viewModel.videoThumbnailUrl {
            // Initialize AVPlayer with the video URL
            let player = AVPlayer(url: videoUrl)
            
            // Create AVPlayerViewController and set the player
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            
            // Present the player view controller
            if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                viewController.present(playerViewController, animated: true) {
                    // Start video playback
                    player.play()
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset the content of the cell
        profileImageView.image = nil  // Reset profile image
        imageView.image = nil         // Reset main image
        profileName.text = ""         // Clear profile name
        postDescriptionLbl.text = ""  // Clear post description
        dateLbl.text = ""             // Clear date label
        page.currentPage = 0          // Reset page control
        page.numberOfPages = 0        // Reset page control number of pages
        likeButton.imageView?.image = nil
        
        // Clear additional images or reset states as needed
        // If using a collection view inside the cell, reload its data
        imageViewCV.reloadData()
        
        // Reset any dynamic constraints or layout needs
        stackHeight?.constant = 10  // Reset or adjust as necessary
        
        // Reset actions or button states if necessary
        likeButton.isSelected = false  // Assuming a like button might have been toggled
        // Similarly, reset other buttons or interactive elements if needed
    }

}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension HomeCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.additionalImages.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCellPhotoCell", for: indexPath) as? NewPostCollectionViewCell else {
                return UICollectionViewCell()
            }
            if let imageUrl = viewModel?.imageUrl(at: indexPath.row) {
                // Update cell's imageView with imageUrl
                cell.imageView.loadImageUsingCache(withUrl: imageUrl.absoluteString, placeholder: UIImage(named: "placeholder"))
            }
            return cell
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        page.currentPage = Int(x / frame.width)
    }
    
    func updateLikeButton(isLiked: Bool) {
        let imageName = isLiked ? "like_selected" : "like_unselected"
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        likeButton.setImage(image, for: .normal)
    }
}

extension HomeCollectionVC: HomeCollectionViewCellDelegate {
    func didTapLikeButton(at indexPath: IndexPath) {
        guard indexPath.row < postsArray.count else {
            print("Index out of bounds")
            return
        }

        let post = postsArray[indexPath.row]
        let newLikeStatus = !post.isLiked // Toggle like status

        // Update like status in Firebase
        FireBaseStore.updatePostLikeStatus(postId: post.postId, isLiked: newLikeStatus) { [weak self] error in
            if let error = error {
                print("Error updating like status: \(error.localizedDescription)")
                return
            }

            // Update local data source
            self?.postsArray[indexPath.row].isLiked = newLikeStatus

            // Reload cell to reflect changes
            DispatchQueue.main.async {
                if let cell = self?.collectionView.cellForItem(at: indexPath) as? HomeCollectionViewCell {
                    cell.updateLikeButton(isLiked: newLikeStatus)
                }
            }
        }
    }
}



extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
