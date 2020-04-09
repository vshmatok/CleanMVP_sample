import UIKit

enum TypeOfAlertMessage {
    case error
    case message
}

// MARK: - Protocols

protocol SignInWithEmailView: BaseView {
    func setSignButton(title: String)
    func setPasswordError(message: String)
    func setEmail(text: String, typeOfMessage: TypeOfAlertMessage)
    func showErrors()
    func signInButton(isEnabled: Bool)
}

protocol SignInWithEmailPresenter: class {
    var router: SignInWithEmailRouter { get }
    var forgotButtonText: String { get }
    var signUpButtonText: String { get }
    var emailPlaceholderText: String { get }
    var passwordPlaceholderText: String { get }
    var navigationBarTitle: String { get }
    func didTappedSignButton()
    func validate(email: String) -> Bool
    func validate(password: String) -> Bool
    func silentValidation(password: String) -> Bool
    func silentValidation(email: String) -> Bool
    func checkEmail(email: String)
}

final class SignInWithEmailPresenterImplementation: SignInWithEmailPresenter {
    
    // MARK: - Properties
    
    var router: SignInWithEmailRouter
    private unowned var view: SignInWithEmailView
    private var useCases: SignInWithEmailUseCases
    private var userParameters: UserParameters = UserParameters()
    private var passwordValidaor: PasswordValidator = PasswordValidator()
    private var emailValidator: EmailValidator = EmailValidator()
    private var isUserRegistered: Bool = true {
        didSet {
            if isUserRegistered == false {
                view.setSignButton(title: "SignWithEmail.signUp.text".localized)
                view.setEmail(text: "SignWithEmail.newUserText".localized, typeOfMessage: .message)
            } else {
                view.setSignButton(title: "SignWithEmail.signIn.text".localized)
                view.setEmail(text: "", typeOfMessage: .message)
            }
        }
    }
    var forgotButtonText: String {
        return "SignWithEmail.forgotPassword.text".localized
    }
    var signUpButtonText: String {
        return "SignWithEmail.signUp.text".localized
    }
    var emailPlaceholderText: String {
        return "SignWithEmail.emailPlaceholder".localized
    }
    var passwordPlaceholderText: String {
        return "SignWithEmail.passwordPlaceholder".localized
    }
    var navigationBarTitle: String {
        return "SignWithEmail.navigationBarTitle".localized
    }

    // MARK: - Configurations
    
    init(view: SignInWithEmailView, router: SignInWithEmailRouter, useCases: SignInWithEmailUseCases) {
        self.view = view
        self.router = router
        self.useCases = useCases
    }
    
    // MARK: - Public
    
    func didTappedSignButton() {
        let isEmailValid = emailValidator.validate(model: userParameters)
        let isPasswordValid = passwordValidaor.validate(model: userParameters)
        guard isEmailValid == nil, isPasswordValid == nil else {
            view.showErrors()
            return
        }
        if isUserRegistered {
            view.showLoader()
            useCases.loginWith(email: userParameters.email, password: userParameters.password) { [weak self] (result) in
                self?.view.hideLoader()
                self?.handleLogin(result: result)
            }
        } else {
            router.openRegisterController(userParameters: userParameters)
        }

    }
    
    func validate(email: String) -> Bool {
        userParameters.email = email
        if let error = emailValidator.validate(model: userParameters) {
            view.setEmail(text: error, typeOfMessage: .error)
            return true
        } else {
            return false
        }
    }
    
    func silentValidation(email: String) -> Bool {
        userParameters.email = email
        if emailValidator.validate(model: userParameters) != nil {
            return true
        } else {
            return false
        }
    }
    
    func validate(password: String) -> Bool {
        userParameters.password = password
        if let error = passwordValidaor.validate(model: userParameters) {
            view.setPasswordError(message: error)
            return true
        } else {
            view.setPasswordError(message: "")
            return false
        }
    }
    
    func silentValidation(password: String) -> Bool {
        userParameters.password = password
        if passwordValidaor.validate(model: userParameters) != nil {
            return true
        } else {
            return false
        }
    }
    
    func checkEmail(email: String) {
        useCases.cancelDownload()
        view.signInButton(isEnabled: false)
        useCases.checkEmail(email: email) { [weak self] (result) in
            switch result {
            case let .success(response):
                self?.view.signInButton(isEnabled: true)
                self?.isUserRegistered = response
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Private
    
    private func handleLogin(result: Result<(user: User, token: String, isSocial: Bool)>) {
        view.hideLoader()
        switch result {
        case let .failure(error):
            view.alert(message: error.localizedDescription)
        case let .success(response):
            print(response.token)
            var responseUser = response.user
            responseUser.isLoginedFromSocials = response.isSocial
            save(token: response.token)
            save(user: responseUser)
            router.openFeed()
        }
    }
    
    private func save(token: String) {
        let keychainService = KeychainService()
        keychainService.sessionToken = token
    }
    
    private func save(user: User) {
        let service = UserService()
        service.save(user: user)
    }
}
