import UIKit

// MARK: - Protocol

protocol SignInWithEmailRouter: ViewRouter {
    func openRegisterController(userParameters: UserParameters)
    func openFeed()
    func openForgotPasswordController()
}

final class SignInWithEmailRouterImplementation: SignInWithEmailRouter {
    
    // MARK: - Segues
    
    private struct Segues {
        static let feedHome: String = "feedHome"
        static let forgotPassword: String = "forgotPasswordSegue"
        static let completeRegistration: String = "completeRegistrationSegue"
    }

    // MARK: - Properties
    
    unowned var controller: SignInWithEmailViewController
    private var userParameters: UserParameters!
    
    // MARK: - Configurations
    
    init(controller: SignInWithEmailViewController) {
        self.controller = controller
    }
    
    // MARK: - Public
    
    func openRegisterController(userParameters: UserParameters) {
        self.userParameters = userParameters
        controller.performSegue(withIdentifier: Segues.completeRegistration, sender: nil)
    }
    
    func openFeed() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let navigationController: UIViewController = UIStoryboard.feed.instantiateViewController(withIdentifier: GlobalConstants.Storyboards.Feed.feedNavgationId)
        appDelegate.window?.rootViewController = navigationController
    }
    
    func openForgotPasswordController() {
        controller.performSegue(withIdentifier: Segues.forgotPassword, sender: nil)
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.completeRegistration {
            let destination = segue.destination as? CompleteRegistrationViewController
            let configurator = CompleteRegistrationConfiguratorImplementation(userParameters: userParameters)
            destination?.configurator = configurator
        }
    }
}
