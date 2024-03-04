//
//  FeedViewModel.swift
//  SocialVideoApp
//
//  Created by MA1424 on 29/02/24.
//

import UIKit

class PostViewModel {
    private let post: Post
    
    var isVideo: Bool {
        return post.videoUrl != ""
    }
    
    var thumbnailUrl: String? {
        if !post.thumbnailUrl.isEmpty {
            return post.thumbnailUrl
        } else {
            return nil
        }
    }
    
    
    var videoThumbnailUrl: URL? {
        // Convert video URL string to URL
        return URL(string: post.videoUrl)
    }
    
    var additionalImages: [URL] {
        var images = [URL]()
        // Append thumbnail URL if it exists
        if !post.thumbnailUrl.isEmpty {
            if let thumbnailUrl = URL(string: post.thumbnailUrl) {
                images.append(thumbnailUrl)
            }
        }
        // Append additional images URLs
        for (_, url) in post.additionalImages {
            if let additionalImageUrl = URL(string: url) {
                images.append(additionalImageUrl)
            }
        }
        return images
    }
    
    var isPostLiked: Bool? = false  // This would ideally come from your model or user preferences
    
    var profileNameText: String {
        return post.username
    }
    
    var postDescriptionText: NSAttributedString {
        let attrs1 = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.black]
        let attrs2 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.black]
        let attributedString1 = NSMutableAttributedString(string: post.username, attributes: attrs1)
        let attributedString2 = NSMutableAttributedString(string: " " + post.post, attributes: attrs2)
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    var profileImageUrl: URL? {
        return URL(string: post.profilePictureUrl)
    }
    
    var dateText: String {
        // Assuming you have a function to format dates
        return Utils.getTimeElapsed(post.created)
    }
    
    var numberOfPages: Int {
        return additionalImages.count
    }
    
    init(post: Post) {
        self.post = post
    }
    
    func imageUrl(at index: Int) -> URL? {
        guard index < additionalImages.count else { return nil }
        return additionalImages[index]
    }
}
