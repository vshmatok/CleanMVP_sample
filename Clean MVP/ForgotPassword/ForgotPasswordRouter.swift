import UIKit

// MARK: - Protocols

protocol ForgotPasswordRouter: ViewRouter {
    func popController()
}

final class ForgotPasswordRouterImplementation: ForgotPasswordRouter {
    
    // MARK: - Properties
    
    private unowned var viewController: ForgotPasswordViewController
    
    // MARK: - Configurations
    
    init(viewController: ForgotPasswordViewController) {
        self.viewController = viewController
    }
    
    // MARK: - ForgotPasswordRouter
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    func popController() {
        viewController.navigationController?.popViewController(animated: true)
    }
}
