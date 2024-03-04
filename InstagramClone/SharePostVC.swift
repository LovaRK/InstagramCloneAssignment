//
//  FeedViewModel.swift
//  SocialVideoApp
//
//  Created by MA1424 on 29/02/24.
//

import UIKit
import Firebase
import Photos
import AVFoundation

class SharePostVC: UIViewController, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ImagePickerDelegate, CancelablePhotoCellDelegate {
  
    

    // MARK: - Properties
    var viewModel: SharePostViewModel!
    var imagePicker: ImagePicker!
    let cellID = "SharePostCells"

    // UI Components
    var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage
        }
    }
    var selectedVideoURL: URL? // Add selectedVideoURL property
    
    var mediaType: SelectedMediaType = .image

    var supplementaryImages: [UIImage] = []

    lazy var imageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()

    lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.boldSystemFont(ofSize: 14)
        tv.text = "Write something here...✍️"
        tv.textColor = UIColor.lightGray
        return tv
    }()

    lazy var buttonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return view
    }()

    lazy var addImagesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Images", for: .normal)
        button.addTarget(self, action: #selector(addImagesTapped), for: .touchUpInside)
        return button
    }()

    lazy var supplementaryImagesCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.register(CancelablePhotoCell.self, forCellWithReuseIdentifier: cellID)
        cv.isPagingEnabled = true
        return cv
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.hidesWhenStopped = true
        return aiv
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Setup Views
    private func setupViews() {
        view.backgroundColor = .white
        
        // Fetch user data and initialize the viewModel
        FireBaseStore.loadUserData { [weak self] user in
            guard let self = self else { return }
            
            print("selectedImage =======\(String(describing: self.selectedImage))")
            print("selectedVideo =======\(String(describing: self.selectedVideoURL))")
            
            self.viewModel = SharePostViewModel(user: user)
            self.viewModel?.selectedImage = self.selectedImage // Ensure this line is correct based on your viewModel's properties
            self.viewModel?.selectedVideoURL = self.selectedVideoURL
            // Bind ViewModel
            self.bindViewModel() // This assumes you have a bindViewModel method to setup bindings
            // After setting the viewModel, proceed to setup the UI
            DispatchQueue.main.async {
                self.view.addSubview(self.container)
                self.container.addSubview(self.imageView)
                self.container.addSubview(self.textView)
                self.view.addSubview(self.buttonContainer)
                self.buttonContainer.addSubview(self.addImagesButton)
                self.view.addSubview(self.supplementaryImagesCV)
                self.supplementaryImagesCV.delegate = self
                self.supplementaryImagesCV.dataSource = self
                self.view.addSubview(self.activityIndicator)
                
                // Setup UI components
                self.setupContainerView()
                self.setupButtonContainer()
                self.setupSupplementaryCollectionView()
                self.setupActivityIndicator()
                self.setupNavigationBar()
                self.setupImagePicker()
            }
            
            // Check if a video has been selected
            if let selectedVideoURL = self.selectedVideoURL {
                // Set the mediaType to video
                self.mediaType = .video
                // Hide the Add Images button
                self.addImagesButton.isHidden = true
                // Generate thumbnail from the video URL
                if let thumbnail = self.generateThumbnail(for: selectedVideoURL) {
                    // Assign the thumbnail to selectedImage
                    self.selectedImage = thumbnail
                    self.viewModel.selectedImage = thumbnail
                }
            }
        }
    }


    private func setupContainerView() {
        container.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        imageView.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 100, height: 100)
        textView.anchor(top: container.topAnchor, left: imageView.rightAnchor, bottom: container.bottomAnchor, right: container.rightAnchor, paddingTop: 8, paddingLeft: 10, paddingBottom: 8, paddingRight: 10, width: 0, height: 0)
        textView.delegate = self
    }

    private func setupButtonContainer() {
        buttonContainer.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        addImagesButton.centerX(inView: buttonContainer)
        addImagesButton.centerY(inView: buttonContainer)
    }

    private func setupSupplementaryCollectionView() {
        supplementaryImagesCV.anchor(top: container.bottomAnchor, left: view.leftAnchor, bottom: buttonContainer.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 200)
    }

    private func setupActivityIndicator() {
        activityIndicator.center(inView: view)
    }

    private func setupNavigationBar() {
      //  navigationController?.navigationBar.prefersLargeTitles = true
      //  navigationItem.title = "New Post"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(shareButtonTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    private func setupImagePicker() {
        imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    // Function to generate thumbnail from video URL
    private func generateThumbnail(for videoURL: URL) -> UIImage? {
        let asset = AVAsset(url: videoURL)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMake(value: 1, timescale: 2)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print("Error creating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - User Interaction
    @objc private func addImagesTapped() {
        if mediaType == .video {
            addImagesButton.isHidden = true
        } else {
            imagePicker.present(from: view)
        }
    }

    @objc private func shareButtonTapped() {
        guard let comment = textView.text, !comment.isEmpty else {
            showAlert(message: "Please enter a comment for your post")
            return
        }
        viewModel.uploadPost(with: comment)
    }

    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.supplementaryImagesCV.reloadData()
            }
        }

        viewModel.showError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(message: error)
            }
        }

        viewModel.showLoading = { [weak self] show in
            DispatchQueue.main.async {
                show ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
        }

        viewModel.postUploadSuccess = { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }

    // MARK: - Helper Functions
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension SharePostVC {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.supplementaryImages.count
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? CancelablePhotoCell else {
            fatalError("Unexpected cell type")
        }
        cell.setImage(image: supplementaryImages[indexPath.row]) // Set cell image
        cell.delegate = self
        cell.index = indexPath.row // Keep track of the cell's index
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension SharePostVC {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2 , height: 200) // Adjust size as needed
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // Adjust spacing as needed
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // Adjust spacing as needed
    }
}

// MARK: - UITextViewDelegate
extension SharePostVC {
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = !textView.text.isEmpty
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write something here...✍️"
            textView.textColor = UIColor.lightGray
        }
    }
}

// MARK: - ImagePickerDelegate
extension SharePostVC {
    func didSelect(image: UIImage?) {
        if let image = image {
            self.supplementaryImages.append(image)
            self.viewModel.supplementaryImages.append(image)
            self.supplementaryImagesCV.reloadData()
        }
    }
    
    func didSelect(videoURL: URL?) {
        if let videoURL = videoURL {
            selectedVideoURL = videoURL
            mediaType = .video
            addImagesButton.isHidden = true
            if let thumbnail = generateThumbnail(for: videoURL) {
                selectedImage = thumbnail
                viewModel.selectedImage = thumbnail
            }
        }
    }
}

// MARK: - CancelablePhotoCellDelegate
extension SharePostVC {
    func removeItem(index: Int) {
            if index < supplementaryImages.count {
                supplementaryImages.remove(at: index) // Remove the image
                supplementaryImagesCV.reloadData() // Refresh the collection view
            }
        }
}

