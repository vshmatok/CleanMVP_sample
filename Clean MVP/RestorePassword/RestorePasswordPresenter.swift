import Foundation

// MARK: - Protocols

protocol RestorePasswordPresenter: class {
    var titleText: String { get }
    var confirmPasswordPlaceholder: String { get }
    var passwordPlaceholder: String { get }
    var confirmButtonPasswordText: String { get }
    func validate(confirmPassword: String) -> Bool
    func validate(password: String) -> Bool
    func resetPasswordWith(password: String, confirmationPassword: String)
}

protocol ResporePasswordView: BaseView {
    func setPassword(error: String)
    func setConfirmPassword(error: String)
    func showErrors()
    func hideKeyboard()
}

final class RestorePasswordPresenterImplementation: RestorePasswordPresenter {
    
    // MARK: - Properties
    
    private var resetToken: String
    private let router: ResetPasswordRouter
    private unowned var view: ResporePasswordView
    private let userCases: ResetPasswordUseCases
    private var userParameters: UserParameters = UserParameters()
    private var passwordValidator: PasswordValidator = PasswordValidator()
    private var confirmPasswordValidator: ConfirmPasswordValidator = ConfirmPasswordValidator()
    
    var titleText: String {
        return "RestorePassword.title.text".localized
    }
    var confirmPasswordPlaceholder: String {
        return "RestorePassword.placeholder.text".localized
    }
    var passwordPlaceholder: String {
        return "SignWithEmail.passwordPlaceholder".localized
    }
    var confirmButtonPasswordText: String {
        return "ForgotPassword.nextButton".localized
    }
    
    // MARK: - Lifecycle
    
    init(view: ResporePasswordView, userCases: ResetPasswordUseCases, router: ResetPasswordRouter, resetToken: String) {
        self.view = view
        self.userCases = userCases
        self.router = router
        self.resetToken = resetToken
    }
    
    // MARK: - Public
    
    func resetPasswordWith(password: String, confirmationPassword: String) {
        guard !validate(password: password), !validate(confirmPassword: confirmationPassword) else {
            view.showErrors()
            return
        }
        view.showLoader()
        userCases.resetPassword(resetToken: resetToken, newPassword: password) { [weak self] (result) in
            self?.view.hideLoader()
            switch result {
            case .success:
                self?.view.hideKeyboard()
                self?.view.alert(message: "RestorePasswrod.success.text".localized, completion: { [weak self] in
                    self?.router.finishRestoring()
                })
            case let .failure(error):
                self?.view.alert(message: error.localizedDescription)
            }
        }
    }
    
    func validate(password: String) -> Bool {
        userParameters.password = password
        if let error = passwordValidator.validate(model: userParameters) {
            view.setPassword(error: error)
            return true
        } else {
            return false
        }
    }
    
    func validate(confirmPassword: String) -> Bool {
        userParameters.confirmPassword = confirmPassword
        if let error = confirmPasswordValidator.validate(model: userParameters) {
            view.setConfirmPassword(error: error)
            return true
        } else {
            return false
        }
    }
}
