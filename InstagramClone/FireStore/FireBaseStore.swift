//
//  FireStore.swift
//  InstagramClone
//
//  Created by Lova Krishna on 24/04/20.
//  Copyright © 2020 Lova Krishna. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class FireBaseStore {
    
    typealias ErrorCompletion = ((Error?) -> Void)?
    
    // MARK: - Authentication
    
    static func login(withEmail email: String, password: String, completion: ErrorCompletion = nil) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            completion?(error)
        }
    }
    
    static func createUser(email: String, password: String, completion: ErrorCompletion = nil) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            completion?(error)
        }
    }
    
    static func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - User Profile
    
    static func updateProfileInfo(withImage image: Data? = nil, name: String? = nil, completion: ErrorCompletion = nil) {
        guard let user = Auth.auth().currentUser else {
            completion?(NSError(domain: "FireBaseStore", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"]))
            return
        }
        
        var updates: [String: Any] = [:]
        if let name = name {
            updates["username"] = name
        }
        
        if let image = image {
            uploadProfileImage(image) { result in
                switch result {
                case .success(let url):
                    updates["profilePictureUrl"] = url.absoluteString
                    // Now, instead of creating a change request, directly update the database.
                    updateUserData(updates: updates, uid: user.uid, completion: completion)
                case .failure(let error):
                    completion?(error)
                }
            }
        } else if !updates.isEmpty {
            // If there's no image but other details need to be updated.
            updateUserData(updates: updates, uid: user.uid, completion: completion)
        } else {
            // No updates to make.
            completion?(nil)
        }
    }
    
    private static func uploadProfileImage(_ image: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        let profileImgReference = Storage.storage().reference().child("profile_pictures").child("\(UUID().uuidString).png")
        profileImgReference.putData(image, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            profileImgReference.downloadURL { url, error in
                if let url = url {
                    completion(.success(url))
                } else {
                    completion(.failure(error ?? NSError(domain: "FireBaseStore", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                }
            }
        }
    }
    
    private static func updateUserData(updates: [String: Any], uid: String, completion: ErrorCompletion) {
        Database.database().reference().child("users").child(uid).updateChildValues(updates) { error, _ in
            completion?(error)
        }
    }
    
    // MARK: - Fetching Data for App Pages
    
    static func fetchFeed(completion: @escaping ([Post]?, Error?) -> Void) {
        Database.database().reference().child("posts").queryOrdered(byChild: "created").observeSingleEvent(of: .value) { snapshot in
            var posts: [Post] = []
            guard let allPosts = snapshot.value as? [String: Any] else {
                completion(nil, nil)
                return
            }
            for (_, postData) in allPosts {
                if let postDict = postData as? [String: Any] {
                    let post = Post(data: postDict)
                    posts.append(post)
                }
            }
            completion(posts, nil)
        }
    }
    
    static func fetchPost(withId postId: String, completion: @escaping (Post?, Error?) -> Void) {
        Database.database().reference().child("posts").child(postId).observeSingleEvent(of: .value) { snapshot in
            guard let postData = snapshot.value as? [String: Any] else {
                completion(nil, nil)
                return
            }
            let post = Post(data: postData)
            completion(post, nil)
        }
    }
    
    static func fetchUserProfile(forUsername username: String, completion: @escaping (UserProfile?, Error?) -> Void) {
        Database.database().reference().child("users").child(username).observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                completion(nil, nil)
                return
            }
            let userProfile = UserProfile(data: userData)
            completion(userProfile, nil)
        }
    }
    
    // MARK: Fetching User Data
    static func loadUserData(completion: @escaping (UserProfile?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)  // User is not logged in
            return
        }
        
        let userRef = Database.database().reference().child("users").child(uid)
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                completion(nil)  // User data could not be decoded
                return
            }
            let userProfile = UserProfile(data: userData)
            completion(userProfile)
        })
    }
    
    static func fetchUserById(userId: String, completion: @escaping (UserProfile?) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                completion(nil)  // User data could not be decoded
                return
            }
            let userProfile = UserProfile(data: userData)
            completion(userProfile)
        })
    }
    
    static func incrementUserIntegerMetaDataByOne(key: String, completion: ((Error?) -> Void)?) {
        let ref = Database.database().reference().child("users").child(key)
        
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var value = currentData.value as? Int {
                value += 1
                currentData.value = value
            } else {
                currentData.value = 1
            }
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { (error, _, _) in
            completion?(error)
        })
    }
    
    static func fetchPostsForUser(withUID uid: String, completion: @escaping ([Post]?, Error?) -> Void) {
        let postsRef = Database.database().reference().child("posts")
        let query = postsRef.queryOrdered(byChild: "userId").queryEqual(toValue: uid)
        
        query.observeSingleEvent(of: .value, with: { snapshot in
            var posts: [Post] = []
            guard let postsDict = snapshot.value as? [String: [String: Any]] else {
                completion(nil, nil) // No posts found
                return
            }
            for (_, postData) in postsDict {
                let post = Post(data: postData)
                posts.append(post)
            }
            completion(posts, nil)
        }) { error in
            completion(nil, error)
        }
    }
    
        static func updatePostLikeStatus(postId: String, isLiked: Bool, completion: @escaping (Error?) -> Void) {
            let postRef = Database.database().reference().child("posts")
           // loop throgh posts and find correct post
            postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let updateData: [String: Any] = ["isLiked": isLiked]
                    postRef.updateChildValues(updateData)
                } else {
                    print("Post does not exist.")
                }
            })
        }

}
