import UIKit

protocol ResetPasswordRouter: ViewRouter {
    func finishRestoring()
}

final class ResetPasswordRouterImplementation: ResetPasswordRouter {
    
    private unowned var viewController: RestorePasswordViewController
    
    init(viewController: RestorePasswordViewController) {
        self.viewController = viewController
    }
    
    // MARK: - ForgotPasswordRouter
    
    func finishRestoring() {
        viewController.navigationController?.popViewController(animated: true)
    }
}
