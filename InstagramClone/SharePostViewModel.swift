//
//  FeedViewModel.swift
//  SocialVideoApp
//
//  Created by MA1424 on 29/02/24.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class SharePostViewModel {

    // MARK: Properties
    var user: UserProfile?
    var selectedImage: UIImage?
    var selectedVideoURL: URL? // Add selectedVideoURL property
    var supplementaryImages: [UIImage] = []

    // Callbacks for View Controller
    var reloadData: (() -> Void)?
    var showError: ((String) -> Void)?
    var showLoading: ((Bool) -> Void)?
    var postUploadSuccess: (() -> Void)?

    // MARK: Initializer
    init(user: UserProfile?) {
        self.user = user
    }

    // MARK: Public Methods
    func uploadPost(with comment: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            showError?("User must be logged in to upload a post")
            return
        }
        
        showLoading?(true)
        
        // This is the unique identifier for the new post
        let postGroupId = UUID().uuidString
        let storageRef = Storage.storage().reference().child("posts/\(postGroupId)")
        
        // Construct postData dictionary
        var postData: [String: Any] = [
            "postId": postGroupId, // Add post ID
            "username": user?.username ?? "Anonymous", // Add username
            "userId": uid,
            "post": comment,
            "created": Date().timeIntervalSince1970,
            "isLiked": false,
            "profilePictureUrl": user?.profilePictureUrl ?? "" // Add profile picture URL
        ]
        
        // Check if a video is selected
        if let selectedVideoURL = selectedVideoURL {
            // Assign the selectedVideoURL to the videoUrl field in postData
            postData["videoUrl"] = selectedVideoURL.absoluteString
            
            // Save the thumbnail URL for the video
            if let selectedImageData = selectedImage?.jpegData(compressionQuality: 0.5) {
                let thumbnailRef = storageRef.child("thumbnail.jpg")
                thumbnailRef.putData(selectedImageData, metadata: nil) { metadata, error in
                    guard metadata != nil else {
                        self.showError?("Error uploading thumbnail image: \(error?.localizedDescription ?? "Unknown error")")
                        self.showLoading?(false)
                        return
                    }
                    
                    thumbnailRef.downloadURL { (url, error) in
                        guard let thumbnailUrl = url else {
                            self.showError?("Error fetching URL for thumbnail image: \(error?.localizedDescription ?? "Unknown error")")
                            self.showLoading?(false)
                            return
                        }
                        
                        postData["thumbnailUrl"] = thumbnailUrl.absoluteString // Set the thumbnail URL
                        self.uploadPostData(uid: uid, postGroupId: postGroupId, postData: postData)
                    }
                }
            }
        } else if let selectedImageData = selectedImage?.jpegData(compressionQuality: 0.5) {
            // Proceed with uploading images as before
            let mainImageRef = storageRef.child("main.jpg")
            mainImageRef.putData(selectedImageData, metadata: nil) { metadata, error in
                guard metadata != nil else {
                    self.showError?("Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
                    self.showLoading?(false)
                    return
                }
                
                mainImageRef.downloadURL { (url, error) in
                    guard let mainImageUrl = url else {
                        self.showError?("Error fetching URL for image: \(error?.localizedDescription ?? "Unknown error")")
                        self.showLoading?(false)
                        return
                    }
                    
                    postData["thumbnailUrl"] = mainImageUrl.absoluteString // Set the URL of the uploaded image
                    
                    // Upload additional images if there are any
                    self.uploadAdditionalImages(uid: uid, postGroupId: postGroupId) { additionalImagesData in
                        postData["additionalImages"] = additionalImagesData // Set additional images' URLs
                        self.uploadPostData(uid: uid, postGroupId: postGroupId, postData: postData)
                    }
                }
            }
        } else {
            showError?("Please select an image or video to upload")
            showLoading?(false)
        }
    }
    
    private func uploadPostData(uid: String, postGroupId: String, postData: [String: Any]) {
        // Save the post data to the database
        let postRef = Database.database().reference().child("posts").childByAutoId()
        postRef.setValue(postData) { error, _ in
            self.showLoading?(false)
            if let error = error {
                self.showError?("Error saving post data: \(error.localizedDescription)")
            } else {
                self.postUploadSuccess?()
            }
        }
    }

    func numberOfSupplementaryImages() -> Int {
        return supplementaryImages.count
    }

    func imageForItemAt(index: Int) -> UIImage? {
        guard index < supplementaryImages.count else { return nil }
        return supplementaryImages[index]
    }

    // MARK: Private Methods
    private func uploadAdditionalImages(uid: String, postGroupId: String, completion: @escaping ([String: String]) -> Void) {
        guard !supplementaryImages.isEmpty else {
            completion([:])
            return
        }

        var uploadedImagesData: [String: String] = [:]
        var uploadCount = 0

        for (index, image) in supplementaryImages.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.5) else { continue }
            let imageName = "image\(index).jpg"
            let imageRef = Storage.storage().reference().child("posts/\(postGroupId)/\(imageName)")

            imageRef.putData(imageData, metadata: nil) { metadata, error in
                uploadCount += 1

                guard metadata != nil else {
                    print("Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
                    if uploadCount == self.supplementaryImages.count {
                        completion(uploadedImagesData)
                    }
                    return
                }

                imageRef.downloadURL { (url, error) in
                    if let downloadURL = url?.absoluteString {
                        uploadedImagesData["url\(index + 1)"] = downloadURL
                    } else {
                        print("Download URL error: \(error?.localizedDescription ?? "Unknown Error")")
                    }

                    if uploadCount == self.supplementaryImages.count {
                        completion(uploadedImagesData)
                    }
                }
            }
        }
    }
}
