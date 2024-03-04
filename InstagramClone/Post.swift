//
//  FeedViewModel.swift
//  SocialVideoApp
//
//  Created by MA1424 on 29/02/24.
//

import Foundation

// MARK: - Model

struct UserCredentials {
    let email: String
    let password: String
}

struct Post: Codable {
    let postId: String
    let videoUrl: String
    let username: String
    let thumbnailUrl: String
    let profilePictureUrl: String
    var additionalImages: [String: String]
    let post: String
    let userId: String
    let created: TimeInterval
    var likes: Int // var because likes can change
    var isLiked: Bool
    
    init(data: [String: Any]) {
        self.postId = data["postId"] as? String ?? ""
        self.videoUrl = data["videoUrl"] as? String ?? ""
        self.thumbnailUrl = data["thumbnailUrl"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.profilePictureUrl = data["profilePictureUrl"] as? String ?? ""
        self.post = data["post"] as? String ?? ""
        self.userId = data["userId"] as? String ?? ""
        self.created = data["created"] as? TimeInterval ?? 0
        self.likes = data["likes"] as? Int ?? 0
        self.additionalImages =  data["additionalImages"] as? [String: String] ?? [:]
        self.isLiked = data["isLiked"] as? Bool ?? false
    }
}

struct UserProfile: Codable {
    let username: String
    let profilePictureUrl: String
    var posts: [String] // Array of post IDs
    
    init(data: [String: Any]) {
        self.username = data["username"] as? String ?? ""
        self.profilePictureUrl = data["profilePictureUrl"] as? String ?? ""
        self.posts = data["posts"] as? [String] ?? []
    }

}

