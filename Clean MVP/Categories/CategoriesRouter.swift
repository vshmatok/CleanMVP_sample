import UIKit

// MARK: - Protocols

protocol CategoriesRouter: ViewRouter, StartScreenRouter {
    func showFeed()
}

final class CategoriesRouterImplementation: CategoriesRouter {
    
    // MARK: - Segues
    
    private struct Segues {
        static let showFeed: String = "feed"
    }
    
    // MARK: - Properties
    
    private unowned var viewController: CategoriesViewController
    weak var source: UIViewController!
    
    // MARK: - LifeCycle
    
    init(viewController: CategoriesViewController) {
        self.source = viewController
        self.viewController = viewController
    }
    
    // MARK: - CategoriesRouter
    
    func showFeed() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let navigationController: UIViewController = UIStoryboard.feed.instantiateViewController(withIdentifier: GlobalConstants.Storyboards.Feed.feedNavgationId)
        appDelegate.window?.rootViewController = navigationController
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
