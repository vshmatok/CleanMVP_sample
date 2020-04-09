import UIKit

// MARK: - Protocol

protocol CompleteRegistrationRouter: ViewRouter {
    func openFeed()
    func showCategories()
    func openCamera(delegate: CreateCameraPostPresenterDelegate?)
}

final class CompleteRegistrationRouterImplementation: CompleteRegistrationRouter {
    
    // MARK: - Segues
    
    private struct Segues {
        static let feedHome: String = "feedHome"
        static let categories: String = "categories"
        static let photoVideoRecorder: String = "photoVideoRecorder"
    }
    
    // MARK: - Properties
    
    unowned var controller: CompleteRegistrationViewController
    
    // MARK: - Configurations
    
    init(controller: CompleteRegistrationViewController) {
        self.controller = controller
    }
    
    // MARK: - Public
    
    func openFeed() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let navigationController: UIViewController = UIStoryboard.feed.instantiateViewController(withIdentifier: GlobalConstants.Storyboards.Feed.feedNavgationId)
        appDelegate.window?.rootViewController = navigationController
    }

    func showCategories() { 
        let categoriesController = UIStoryboard.feed.instantiateViewController(withIdentifier: GlobalConstants.Storyboards.Feed.categoriesNavgationId)
        let segue = ReplaceRootViewControllerSegue(identifier: Segues.categories, source: controller, destination: categoriesController)
        segue.perform()
    }
    
    func openCamera(delegate: CreateCameraPostPresenterDelegate?) {
        let cameraScreen = UIStoryboard.createPost.instantiateViewController(withIdentifier: GlobalConstants.Storyboards.CreatePost.photoVideoRecorder) as! CreateCameraPostViewController
        let configurator = CreateCameraPostConfiguratorImplementation(typeOfPost: .photo, createCameraPostDelegate: delegate, postPreviewUnwind: nil, categoryPreviewObjectSource: nil)
        configurator.configurate(contoller: cameraScreen)
        cameraScreen.configurator = configurator
        controller.navigationController?.pushViewController(cameraScreen, animated: true)
    }
    
}
