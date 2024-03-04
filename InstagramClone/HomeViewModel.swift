//
//  FeedViewModel.swift
//  SocialVideoApp
//
//  Created by MA1424 on 29/02/24.
//
import Foundation

class HomeViewModel {
    
    var posts: [Post] = []
    var user: UserProfile?
    
    func fetchData(completion: @escaping () -> Void) {
        FireBaseStore.loadUserData { [weak self] (user) in
            self?.user = user
            FireBaseStore.fetchFeed { (fetchedPosts, error) in
                if let fetchedPosts = fetchedPosts {
                    self?.posts = fetchedPosts.sorted(by: { $0.created > $1.created })
                }
                completion()
            }
        }
    }
}
