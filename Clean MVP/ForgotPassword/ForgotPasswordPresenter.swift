import UIKit

protocol ForgotPasswordView: BaseView {
    func hideKeyboard()
    func setEmail(text: String)
    func showErrors()
}

protocol ForgotPasswordPresenter {
    var titleText: String { get }
    var subtitleText: String { get }
    var emailPlaceholderText: String { get }
    var doneButtonText: String { get }
    var router: ForgotPasswordRouter { get }
    func resetPasswordWith(email: String)
    func validate(email: String) -> Bool
}

final class ForgotPasswordPresenterImplementation: ForgotPasswordPresenter {
    
    // MARK: - Properties
    
    let router: ForgotPasswordRouter
    private unowned var view: ForgotPasswordView
    private let userCases: ForgotPasswordUseCases
    private var userParameters: UserParameters = UserParameters()
    private var emailValidator: EmailValidator = EmailValidator()
    var titleText: String {
        return "ForgotPassword.title".localized
    }
    var subtitleText: String {
        return "ForgotPassword.subtitle".localized
    }
    var emailPlaceholderText: String {
        return "SignWithEmail.emailPlaceholder".localized
    }
    var doneButtonText: String {
        return "ForgotPassword.nextButton".localized
    }
    
    // MARK: - Lifecycle
    
    init(view: ForgotPasswordView, userCases: ForgotPasswordUseCases, router: ForgotPasswordRouter) {
        self.view = view
        self.userCases = userCases
        self.router = router
    }
    
    // MARK: - ForgotPasswordPresenter
    
    func resetPasswordWith(email: String) {
        guard !validate(email: email) else {
            view.showErrors()
            return
        }
        view.showLoader()
        userCases.resetPassword(email: email, completion: { [weak self] (result) in
            self?.view.hideLoader()
            switch result {
            case .success:
                self?.view.hideKeyboard()
                self?.view.alert(message: "ForgotPassword.success".localized, completion: { [weak self] in
                    self?.router.popController()
                })
            case let .failure(error):
                self?.view.alert(message: error.localizedDescription)
            }
        })
    }
    
    func validate(email: String) -> Bool {
        userParameters.email = email
        if let error = emailValidator.validate(model: userParameters) {
            view.setEmail(text: error)
            return true
        } else {
            return false
        }
    }

}
