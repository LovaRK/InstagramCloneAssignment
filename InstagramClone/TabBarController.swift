import UIKit
import Firebase


class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        delegate = self
    }
    
    private func setupViewControllers() {
        view.backgroundColor = .white
        let tabs = [createHomeTab(), createPostTab(), createProfileTab()]
        self.viewControllers = tabs.map { $0.navigationController }
        configureTabItems()
    }
    
    private func createHomeTab() -> (viewController: UIViewController, navigationController: UINavigationController) {
        let viewController = HomeCollectionVC(collectionViewLayout: UICollectionViewFlowLayout())
        return createTab(for: viewController, title: "Home", image: "home_unselected", selectedImage: "home_selected")
    }
    
    private func createPostTab() -> (viewController: UIViewController, navigationController: UINavigationController) {
        let viewController = UIViewController() // Replace with actual view controller
        return createTab(for: viewController, title: "Post", image: "plus_unselected", selectedImage: "plus_unselected")
    }
    
    private func createProfileTab() -> (viewController: UIViewController, navigationController: UINavigationController) {
        let viewController = ProfileCollectionVC(collectionViewLayout: UICollectionViewFlowLayout())
        return createTab(for: viewController, title: "Profile", image: "profile_unselected", selectedImage: "profile_selected")
    }
    
    private func createTab(for rootViewController: UIViewController, title: String, image: String, selectedImage: String) -> (viewController: UIViewController, navigationController: UINavigationController) {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        configureTabBarItem(for: navigationController, title: title, image: image, selectedImage: selectedImage)
        return (rootViewController, navigationController)
    }
    
    private func configureTabBarItem(for navigationController: UINavigationController, title: String, image: String, selectedImage: String) {
        let tabBarItem = navigationController.tabBarItem
        tabBarItem?.title = title
        tabBarItem?.image = UIImage(named: image)
        tabBarItem?.selectedImage = UIImage(named: selectedImage)
    }
    
    private func configureTabItems() {
        let tabFontSize: CGFloat = 10
        let tabFont: UIFont = .systemFont(ofSize: tabFontSize)
        let normalAttributes: [NSAttributedString.Key: Any] = [.font: tabFont]
        tabBar.items?.forEach { item in
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            item.setTitleTextAttributes(normalAttributes, for: .normal)
        }
    }
    
     func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController) else {
            return true
        }
        if index == 1 {
            presentNewPostController()
            return false
        }
        return true
    }

    private func presentNewPostController() {
        let flowLayout = UICollectionViewFlowLayout()
        let newPostVC = NewPostCollectionVC(collectionViewLayout: flowLayout)
        let newPostNavController = UINavigationController(rootViewController: newPostVC)
        newPostNavController.modalPresentationStyle = .fullScreen
        present(newPostNavController, animated: true, completion: nil)
    }
}



