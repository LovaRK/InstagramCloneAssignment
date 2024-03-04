//
//  FeedViewModel.swift
//  SocialVideoApp
//
//  Created by MA1424 on 29/02/24.
//

import UIKit
import Firebase

class HomeCollectionVC: UICollectionViewController {
    
    private let reuseIdentifier = "Cell"
    var postsArray = [Post]()
   // var user : UserProfile?
    var refreshControl = UIRefreshControl() // Add refresh control

    
    let titleView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "Instagram_logo_white").withRenderingMode(.alwaysOriginal)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureNavBar()
        // Configure refresh control
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Trigger refresh control when the view appears
        refreshControl.beginRefreshing()
        refreshData()
    }
    
    @objc func refreshData() {
            getDataFromFireBase {
                // Stop refreshing when data is fetched
                self.refreshControl.endRefreshing()
            }
        }
    
    fileprivate func getDataFromFireBase(completion: (() -> Void)? = nil) {
        // Display activity indicator before loading data
        self.displayActivityIndicator(shouldDisplay: true)

        // Fetch all posts from Firebase
        FireBaseStore.fetchFeed { [weak self] (posts, error) in
            DispatchQueue.main.async {
                // Hide activity indicator after loading data
                self?.displayActivityIndicator(shouldDisplay: false)

                if let error = error {
                    // Handle any errors, for example, by showing an alert to the user
                    print("Error fetching posts: \(error)")
                } else if let posts = posts {
                    // Successfully fetched posts, update the data source of your collection view
                    self?.postsArray = posts.sorted(by: { $0.created > $1.created })
                    self?.updateCollectionView()
                    // Reload the collection view to display the new posts
                    self?.collectionView.reloadData()
                }
                completion?()
            }
        }
    }

    
    func configureView() {
        // Register cell classes
        self.collectionView!.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func configureNavBar() {
        self.collectionView.backgroundColor = .white
        navigationItem.titleView            = titleView
      //  navigationItem.leftBarButtonItem    = UIBarButtonItem(image: #imageLiteral(resourceName: "showCamera"), style: .plain, target: self, action: #selector(cemaraButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.square"), style: .plain, target: self, action: #selector(postButtonPressed))

    }
    
    func updateCollectionView() {
          if postsArray.isEmpty {
              collectionView.setEmptyMessage("No items available")
          } else {
              collectionView.restore()
          }
          collectionView.reloadData()
      }
    
    @objc func cemaraButtonTapped() {
        
    }
    
    @objc func postButtonPressed() {
        self.presentNewPostController()
    }
    
    private func presentNewPostController() {
        let flowLayout = UICollectionViewFlowLayout()
        let newPostVC = NewPostCollectionVC(collectionViewLayout: flowLayout)
        let newPostNavController = UINavigationController(rootViewController: newPostVC)
        newPostNavController.modalPresentationStyle = .fullScreen
        present(newPostNavController, animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if postsArray.isEmpty {
            collectionView.setEmptyMessage("No items available")
        } else {
            collectionView.restore() // Make sure to restore the normal state if there are items
            collectionView.reloadData()
        }
        return postsArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeCollectionViewCell
        // Configure the cell
        cell.indexPath = indexPath
        cell.delegate = self // Set delegate to handle like button tap
        let post = postsArray[indexPath.row]
        cell.viewModel = PostViewModel(post: post)
        cell.updateLikeButton(isLiked: post.isLiked) 
        return cell
    }
}

extension HomeCollectionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.item < postsArray.count else {
                // Return a default size or log an error if the index is out of bounds
                return CGSize(width: view.frame.width, height: 200) // Example default size
            }

            // Safely access the post using the index
            let post = postsArray[indexPath.item]
            let textHeight = Utils.heightForView(post: post, width: view.frame.width - 16)
            var height = (view.frame.width - 100) + 50 + 56 + textHeight + 5 // Adjust this calculation as necessary
            
            // Uncomment and adjust the following if you need to account for additional images
             if post.additionalImages.count > 0 {
                 height += 10
             }
            
            return CGSize(width: view.frame.width, height: height)
    }
}

