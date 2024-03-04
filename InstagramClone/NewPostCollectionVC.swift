//
//  FeedViewModel.swift
//  SocialVideoApp
//
//  Created by MA1424 on 29/02/24.
//

import UIKit
import Photos



enum SelectedMediaType {
    case image, video
}


class NewPostCollectionVC: UICollectionViewController {
    
    private let cellReuseIdentifier = "NewPostCell"
    private let newPostHeaderReuseIdentifier = "ProfileHeader"
    
    var headerView: NewPostCollectionViewCell?
    var images: [UIImage] = []
    var assets: [PHAsset] = []
    var selectedIndex = 0
    
    var index: Int?
    
    var selectedMediaType: SelectedMediaType?

    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        self.fetchMediaFromDevice()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 0
        self.selectedMediaType = .image
        self.setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // Changed from viewDidAppear to viewWillAppear
        // The media fetch can be initiated here if you prefer fetching new content every time the view appears.
        self.setup()
    }
    
    fileprivate func setup() {
        self.view.backgroundColor = UIColor.white
        self.collectionView.backgroundColor = UIColor.clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(NewPostCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.register(NewPostCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: newPostHeaderReuseIdentifier)
    }
    
    fileprivate func setupNavigationBar() {
        self.navigationItem.title = "Select Photo"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonTapped))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
    }
    
    @objc func nextButtonTapped() {
        guard let selectedType = selectedMediaType else { return }

        FireBaseStore.loadUserData { [weak self] user in
            DispatchQueue.main.async {
                guard let user = user, let self = self else { return }
                let controller = SharePostVC()
                
                // Determine whether to pass image or video
                if selectedType == .image {
                    controller.selectedImage = self.images[self.selectedIndex]
                    controller.mediaType = .image // Set media type to image
                    
                } else if selectedType == .video {
                    self.getVideoURL(for: self.selectedIndex) { videoURL in
                        if let videoURL = videoURL {
                            // If video URL is available, generate its thumbnail
                            if let thumbnail = self.generateThumbnail(for: videoURL) {
                                controller.selectedImage = thumbnail
                                controller.selectedVideoURL = videoURL
                                controller.mediaType = .video // Set media type to video
                            }
                        }
                    }
                }
                
                controller.viewModel = SharePostViewModel(user: user)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
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

    
    func getVideoURL(for index: Int, completion: @escaping (URL?) -> Void) {
        let asset = assets[index]
        guard asset.mediaType == .video else {
            completion(nil)
            return
        }

        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, _, _) in
            DispatchQueue.main.async {
                guard let avURLAsset = avAsset as? AVURLAsset else {
                    completion(nil)
                    return
                }
                let videoURL = avURLAsset.url
                completion(videoURL)
            }
        }
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func fetchMediaFromDevice() {
        images = []
        assets = []
        let imageManager = PHImageManager.default()
        let options = PHFetchOptions()
        options.fetchLimit = 100
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let allAssets = PHAsset.fetchAssets(with: options)
        let reqOptions = PHImageRequestOptions()
        reqOptions.isSynchronous = true

        allAssets.enumerateObjects { [unowned self] (asset, count, _) in
            switch asset.mediaType {
            case .image:
                imageManager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: reqOptions) { [unowned self] (image, _) in
                    if let image = image {
                        self.assets.append(asset)
                        self.images.append(image)
                        if count == allAssets.count - 1 {
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            case .video:
                imageManager.requestAVAsset(forVideo: asset, options: nil) { [unowned self] (avAsset, _, _) in
                    if let avAsset = avAsset, let track = avAsset.tracks(withMediaType: .video).first {
                        let assetImgGenerate = AVAssetImageGenerator(asset: avAsset)
                        assetImgGenerate.appliesPreferredTrackTransform = true
                        let time = CMTimeMake(value: 1, timescale: 2)
                        do {
                            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                            let thumbnail = UIImage(cgImage: img)
                            self.assets.append(asset)
                            self.images.append(thumbnail)
                        } catch {
                            print("Error creating thumbnail: \(error.localizedDescription)")
                        }
                        if count == allAssets.count - 1 {
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            default:
                break // Unsupported media types are ignored
            }
        }
    }
    
    fileprivate func loadResolutionImage(index: Int) {
        let imageManager = PHImageManager.default()
        let reqOptions = PHImageRequestOptions()
        reqOptions.isSynchronous = true
        imageManager.requestImage(for: assets[index], targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill, options: reqOptions) { [unowned self] (image, _) in
            if let image = image {
                self.headerView?.setImage(image: image)
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! NewPostCollectionViewCell
        // Configure the cell
        let image = images[indexPath.item]
        cell.imageView.contentMode = .scaleAspectFill
        cell.setImage(image: image)
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.item
        let selectedAsset = assets[selectedIndex]
        switch selectedAsset.mediaType {
        case .image:
            selectedMediaType = .image
            loadResolutionImage(index: selectedIndex) // Loads high-resolution image
        case .video:
            selectedMediaType = .video
            loadResolutionImage(index: selectedIndex) // If you are using thumbnails for videos
        default:
            break
        }
        collectionView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (view.frame.width - 3) / 3
        return CGSize(width: size, height: size)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind:
        String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:
            newPostHeaderReuseIdentifier, for: indexPath) as! NewPostCollectionViewCell
        self.headerView = header
        if assets.count > 0 {
            loadResolutionImage(index: selectedIndex)
        }
        return header
    }
}

extension NewPostCollectionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection
        section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.width)
    }
}
