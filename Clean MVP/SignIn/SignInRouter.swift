import Foundation
import UIKit

// MARK: - Protocols

protocol SignInRouter: ViewRouter {
    func openTermsScreen(type: TypeOfTerms)
    func openLoginWithEmail()
    func showFeedScreen()
    func openRegisterController(userParameters: UserParameters)
}

final class SignInRouterImplementation: SignInRouter {
    
    // MARK: - Segues
    
    private struct Segues {
        static let createProfile: String = "LoginWithEmail"
        static let feedHome: String = "feedHome"
        static let emailSign: String = "emailSignIn"
        static let completeRegistration: String = "completeRegistrationSegue"
    }

    // MARK: - Properties
    
    private unowned var controller: SignInViewController
    private var userParameters: UserParameters!

    // MARK: - Configurations
    
    init(controller: SignInViewController) {
        self.controller = controller
    }
    
    // MARK: - Public
    
    func openTermsScreen(type: TypeOfTerms) {
        let controller = UIStoryboard.settings.instantiateViewController(withIdentifier: GlobalConstants.Storyboards.Settings.privacyController) as! PrivacyPolicyViewController
        let configurator = PrivacyPolicyConfiguratorImplementation(typeOfTerms: type)
        controller.configurator = configurator
        self.controller.navigationController?.pushViewController(controller, animated: true)
    }

    func openLoginWithEmail() {
        controller.performSegue(withIdentifier: Segues.emailSign, sender: nil)
    }
    
    func showFeedScreen() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let navigationController: UIViewController = UIStoryboard.feed.instantiateViewController(withIdentifier: GlobalConstants.Storyboards.Feed.feedNavgationId)
        appDelegate.window?.rootViewController = navigationController
    }
    
    func openRegisterController(userParameters: UserParameters) {
        self.userParameters = userParameters
        controller.performSegue(withIdentifier: Segues.completeRegistration, sender: nil)
    }

    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.completeRegistration {
            let destination = segue.destination as? CompleteRegistrationViewController
            let configurator = CompleteRegistrationConfiguratorImplementation(userParameters: userParameters)
            destination?.configurator = configurator
        }
    }
}
