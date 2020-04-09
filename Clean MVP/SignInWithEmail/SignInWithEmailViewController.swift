import UIKit

class SignInWithEmailViewController: LoaderAlertViewController {

    // MARK: - Properties
    
    @IBOutlet private weak var emailCheckActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    @IBOutlet private weak var signActionButton: UIButton!
    @IBOutlet private weak var passwordAlertMessageLabel: UILabel!
    @IBOutlet private weak var passwordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet private weak var emailAlertMessageLabel: UILabel!
    @IBOutlet private weak var emailTextField: SkyFloatingLabelTextField!
    private var configurator: SignInWithEmailConfigurator = SignInWithEmailConfiguratorImplementation()
    var presenter: SignInWithEmailPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configurate(controller: self)
        localizeUI()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        presenter.router.prepare(for: segue, sender: sender)
    }

    // MARK: - IBActions
    
    @IBAction private func didTappedForgotPasswordButton(_ sender: UIButton) {
        presenter.router.openForgotPasswordController()
    }
    
    @IBAction private func didTappedSignButton(_ sender: UIButton) {
        presenter.didTappedSignButton()
    }
    
    @IBAction private func didCangeValueInTextFields(_ sender: SkyFloatingLabelTextField) {
        guard let text = sender.text else {
            return
        }
        if sender == emailTextField {
            if !presenter.silentValidation(email: text) {
                presenter.checkEmail(email: text)
            }
        }
    }
    
    @IBAction private func didTappedView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: - Private
    
    private func localizeUI() {
        navigationItem.title = presenter.navigationBarTitle
        forgotPasswordButton.setTitle(presenter.forgotButtonText, for: .normal)
        signActionButton.setTitle(presenter.signUpButtonText, for: .normal)
        passwordTextField.placeholder = presenter.passwordPlaceholderText
        passwordTextField.title = presenter.passwordPlaceholderText
        emailTextField.placeholder = presenter.emailPlaceholderText
        emailTextField.title = presenter.emailPlaceholderText
    }
}

// MARK: - SignInWithEmailView

extension SignInWithEmailViewController: SignInWithEmailView {
    
    func showErrors() {
        emailTextField.becomeFirstResponder()
        passwordTextField.becomeFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    func setSignButton(title: String) {
        signActionButton.setTitle(title, for: .normal)
    }
    
    func setPasswordError(message: String) {
        self.passwordAlertMessageLabel.text = message
    }
    
    func setEmail(text: String, typeOfMessage: TypeOfAlertMessage) {
        emailAlertMessageLabel.text = text
        if typeOfMessage == .message {
            emailAlertMessageLabel.textColor = UIColor(red: 255 / 255, green: 165 / 255, blue: 0, alpha: 1)
        } else {
            emailAlertMessageLabel.textColor = .red
        }
    }
    
    func signInButton(isEnabled: Bool) {
        setSignButton(title: "")
        emailCheckActivityIndicator.isHidden = isEnabled
        isEnabled ? emailCheckActivityIndicator.stopAnimating() : emailCheckActivityIndicator.startAnimating()
        signActionButton.isEnabled = isEnabled
    }

}

extension SignInWithEmailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textField = textField as? SkyFloatingLabelTextField, let text = textField.text else {
            return
        }
        if textField == emailTextField {
            emailTextField.errorMessage = presenter.validate(email: text) ? presenter.emailPlaceholderText : ""
        } else {
            passwordTextField.errorMessage = presenter.validate(password: text) ? presenter.passwordPlaceholderText : ""
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField {
            if !(emailTextField.errorMessage ?? "").isEmpty {
                setEmail(text: "", typeOfMessage: .error)
            }
            emailTextField.errorMessage = ""
        } else {
            passwordTextField.errorMessage = ""
            setPasswordError(message: "")
        }
    }
}
