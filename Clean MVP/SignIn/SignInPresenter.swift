import Foundation
import UIKit

// MARK: - Protocols

protocol SignInView: BaseView {
}

protocol SignInPresenter: class {
    var router: SignInRouter { get }
    var signInText: String { get }
    var facebookText: String { get }
    var googleText: String { get }
    var emailText: String { get }
    var skipButtonText: String { get }
    var linkAttributes: [String: Any] { get }
    func getTransformationFor(imageView: UIImageView) -> CGAffineTransform
    func show(message: String)
    func didTappedLoginWithGoogle()
    func didTappedLoginWithFacebook()
    func didTappedLoginWithEmail()
    func didTappedSkipLogin()
    func didTappedTextViews(url: String)
    func prepareTermsString() -> NSMutableAttributedString
    func setupPushToken()
}

final class SignInPresenterImplementation: SignInPresenter {

    // MARK: - Local constants
    
    private struct LocalConstants {
        static let privacyPolicyUrl: String = "privacy"
        static let termsOfUseUrl: String = "termsOfUse"
        static let underlineColor: UIColor = UIColor(red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1)
        static let splashLogoDistanceToTop: CGFloat = 0.295 * UIScreen.main.bounds.height
        static let curretLogoDistanceToTop: CGFloat = 92
    }
    
    // MARK: - Enum
    
    private enum SocialType {
        case facebook, google
    }
    
    // MARK: - Properties
    
    var router: SignInRouter
    private unowned var view: SignInView
    private var useCases: SignInUseCases
    private let socialService: SocialServices
    var skipButtonText: String {
        return "Login.skip".localized
    }
    var signInText: String {
        return "Sign in with".localized
    }
    var facebookText: String {
        return "SignIn.facebook".localized
    }
    var googleText: String {
        return "SignIn.google".localized
    }
    var emailText: String {
        return "SignIn.email".localized
    }
    var linkAttributes: [String: Any] {
        return [NSAttributedStringKey.foregroundColor.rawValue: UIColor(red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1)]
    }
    
    // MARK: - Lifecycle
    
    init(view: SignInView, useCases: SignInUseCases, router: SignInRouter, socialService: SocialServices) {
        self.view = view
        self.useCases = useCases
        self.router = router
        self.socialService = socialService
    }
    
    // MARK: - Public
    
    /// This method is for showStartScreen error message handling
    func show(message: String) {
        view.alert(message: message)
    }
    
    func getTransformationFor(imageView: UIImageView) -> CGAffineTransform {
        return CGAffineTransform.identity.translatedBy(x: 0, y: LocalConstants.splashLogoDistanceToTop - LocalConstants.curretLogoDistanceToTop)
    }
    
    func setupPushToken() {
        PushNotificationService.shared.enablePushNotificationWithCompletion { _ in }
    }
    
    func didTappedLoginWithGoogle() {
        socialService.loginWithGoogle { [weak self] (status) in
            self?.view.showLoader()
            self?.socialResponseHandlerFor(status: status, socialType: .google)
        }
    }
    
    func didTappedLoginWithEmail() {
        router.openLoginWithEmail()
    }
    
    func didTappedSkipLogin() {
        view.showLoader()
        useCases.categoriesList(fromPage: nil, perPage: nil) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.view.hideLoader()
            switch result {
            case let .success(responce):
                strongSelf.save(user: User.annonymousUserWith(categories: responce))
                KeychainService().sessionToken = nil
                strongSelf.router.showFeedScreen()
            case let .failure(error):
                strongSelf.view.alert(message: error.localizedDescription)
                strongSelf.view.hideLoader()
            }
        }
    }
    
    func didTappedLoginWithFacebook() {
        socialService.loginWithFacebook { [weak self] (status) in
            self?.view.showLoader()
            self?.socialResponseHandlerFor(status: status, socialType: .facebook)
        }
    }
    
    func didTappedTextViews(url: String) {
        if url == LocalConstants.privacyPolicyUrl {
            router.openTermsScreen(type: .termsOfPrivacy)
        } else {
            router.openTermsScreen(type: .termsOfUse)
        }
    }
    
    func prepareTermsString() -> NSMutableAttributedString {
        let stringWithAttributes: NSMutableAttributedString = NSMutableAttributedString()
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        stringWithAttributes.append(NSAttributedString(string: "By creating your profile, you agree to".localized))
        stringWithAttributes.append(NSAttributedString(string: " "))
        stringWithAttributes.append(NSAttributedString(string: "the terms of our privacy".localized, attributes: [NSAttributedStringKey.link: URL(string: LocalConstants.privacyPolicyUrl)!, NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue, NSAttributedStringKey.underlineColor: LocalConstants.underlineColor]))
        stringWithAttributes.append(NSAttributedString(string: ", "))
        stringWithAttributes.append(NSAttributedString(string: "terms of use".localized, attributes: [NSAttributedStringKey.link: URL(string: LocalConstants.termsOfUseUrl)!, NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue, NSAttributedStringKey.underlineColor: LocalConstants.underlineColor]))
        stringWithAttributes.addAttributes([NSAttributedStringKey.font: UIFont(name: "Avenir-Book", size: 14.0)!, NSAttributedStringKey.foregroundColor: UIColor(red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1), NSAttributedStringKey.paragraphStyle: paragraph], range: NSRange(location: 0, length: stringWithAttributes.length))
        return stringWithAttributes
    }
    
    // MARK: - Private
    
    private func socialResponseHandlerFor(status: SocialServices.SocialServicesStatus, socialType: SocialType) {
        switch status {
        case let .error(error):
            view.hideLoader()
            view.alert(message: error.localizedDescription)
        case .canceled:
            view.hideLoader()
        case let .success(token):
            socialLoginFor(token: token, socialType: socialType)
        }
    }
    
    private func socialLoginFor(token: String, socialType: SocialType) {
        switch socialType {
        case .facebook:
            useCases.facebookLogin(token: token, completion: { [weak self] (result) in
                self?.handleLogin(result: result)
            })
        case .google:
            useCases.googleLogin(token: token) { [weak self] (result) in
                self?.handleLogin(result: result)
            }
        }
    }
    
    private func handleLogin(result: Result<(user: User, token: String, isSocial: Bool)>) {
        view.hideLoader()
        switch result {
        case let .failure(error):
            view.alert(message: error.localizedDescription)
        case let .success(response):
            print(response.token)
            var responseUser = response.user
            responseUser.isLoginedFromSocials = response.isSocial
            let token = response.token
            
            if isAllMandatoryFieldsFilledInUser(model: responseUser) {
                save(token: response.token)
                save(user: responseUser)
                self.router.showFeedScreen()
            } else {
                let userParameters: UserParameters = UserParameters()
                userParameters.configureForCompleatingRegistration(userModel: responseUser, sessionToken: token)
                router.openRegisterController(userParameters: userParameters)
            }
            
        }
    }
    
    private func save(token: String?) {
        let keychainService = KeychainService()
        keychainService.sessionToken = token
    }
    
    private func save(user: User) {
        let service = UserService()
        service.save(user: user)
    }
    
    private func isAllMandatoryFieldsFilledInUser(model: User) -> Bool {
        return !model.bio.isEmpty && !model.address.isEmpty && !(model.fullName ?? "").isEmpty && !model.email.isEmpty
    }
}
