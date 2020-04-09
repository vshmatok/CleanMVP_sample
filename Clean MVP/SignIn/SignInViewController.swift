import UIKit

class SignInViewController: LoaderAlertViewController, SignInView {
    
    // MARK: - Properties
    
    @IBOutlet private weak var signInView: UIView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var signInLabel: UILabel!
    @IBOutlet private weak var facebookButton: UIButton!
    @IBOutlet private weak var googleButton: UIButton!
    @IBOutlet private weak var skipBarBatton: UIBarButtonItem!
    @IBOutlet private weak var emailButton: UIButton!
    @IBOutlet private weak var termsAndPrivacyTextView: UITextView!
    private var configurator: SignInConfigurator = SignInConfiguratorImplementation()
    var presenter: SignInPresenter!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(controller: self)
        configureTextView()
        configurateLogo()
        localizeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logoSlideAnimation()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        presenter.router.prepare(for: segue, sender: sender)
    }
    
    // MARK: - IBActions
    
    @IBAction private func didTappedSkipLogin(_ sender: Any) {
        presenter.didTappedSkipLogin()
    }
    
    @IBAction private func didTappedFacebookButton(_ sender: UIButton) {
        presenter.didTappedLoginWithFacebook()
    }
    
    @IBAction private func didTappedGoogleButton(_ sender: UIButton) {
        presenter.didTappedLoginWithGoogle()
    }
    
    @IBAction private func didTappedEmailButton(_ sender: UIButton) {
        presenter.didTappedLoginWithEmail()
    }
    
    // MARK: - Private
    
    private func logoSlideAnimation() {
        UIView.animate(withDuration: GlobalConstants.longTimeAnimation,
                       animations: {
                        self.logoImageView.transform = CGAffineTransform.identity
        },
                       completion: { (_) in
                        UIView.animate(withDuration: GlobalConstants.longTimeAnimation, animations: {
                            self.signInView.alpha = 1
                            self.termsAndPrivacyTextView.alpha = 0.47
                        })
        })
    }
    
    private func localizeUI() {
        skipBarBatton.title = presenter.skipButtonText
        signInLabel.text = presenter.signInText
        facebookButton.setTitle(presenter.facebookText, for: .normal)
        googleButton.setTitle(presenter.googleText, for: .normal)
        emailButton.setTitle(presenter.emailText, for: .normal)
        termsAndPrivacyTextView.attributedText = presenter.prepareTermsString()
        termsAndPrivacyTextView.sizeToFit()
    }
    
    private func configureTextView() {
        termsAndPrivacyTextView.textContainerInset = .zero
        termsAndPrivacyTextView.textContainer.lineFragmentPadding = 0
        termsAndPrivacyTextView.linkTextAttributes = presenter.linkAttributes
    }
    
    private func configurateLogo() {
        logoImageView.transform = presenter.getTransformationFor(imageView: logoImageView)
    }
    
}

// MARK: - UITextViewDelegate

extension SignInViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        presenter.didTappedTextViews(url: URL.absoluteString)
        return false
    }
}
