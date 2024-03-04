//
//  FeedViewModel.swift
//  SocialVideoApp
//
//  Created by MA1424 on 29/02/24.
//

import Foundation
import UIKit

class HomeCellViewModel {
    private var post: Post
    
    init(post: Post) {
        self.post = post
    }
    
    var thumbnailUrl: String {
        return post.thumbnailUrl
    }
    
    var username: String {
        return post.username
    }
    
    var postDescription: NSAttributedString {
        let attrs1 = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.black]
        let attrs2 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.black]
        let attributedString1 = NSMutableAttributedString(string: post.username + ": ", attributes: attrs1)
        let attributedString2 = NSMutableAttributedString(string: post.post, attributes: attrs2)
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    var postDate: String {
        // Convert the post.created to a readable date string
        return Utils.getTimeElapsed(post.created) // Make sure this function exists and works as expected
    }
    
    var additionalImages: [String] {
        var images = [post.thumbnailUrl]
        images.append(contentsOf: post.additionalImages.map { $0.value }) // Assuming additionalImages is a dictionary
        return images
    }
    
    var numberOfPages: Int {
        return post.additionalImages.count
    }
    
    var likesCount: Int {
        return post.likes
    }
    
    var isLiked: Bool {
        return post.isLiked
    }
}
