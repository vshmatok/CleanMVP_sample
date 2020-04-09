import UIKit

final class ForgotPasswordViewController: LoaderAlertViewController {
    
    // MARK: - Properties
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var errorMessageLabel: UILabel!
    @IBOutlet private weak var completeButton: UIButton!
    private var configurator: ForgotPasswordConfigurator = ForgotPasswordConfiguratorImplementation()
    var presenter: ForgotPasswordPresenter!

    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(viewController: self)
        localizeUI()
    }
    
    // MARK: - IBActions
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        presenter.resetPasswordWith(email: emailTextField.text ?? "")
    }
    
    @IBAction private func didTappedView(_ sender: UITapGestureRecognizer) {
        hideKeyboard()
    }
    
    // MARK: - Private
    
    private func localizeUI() {
        navigationItem.title = presenter.titleText
        titleLabel.text = presenter.subtitleText
        completeButton.setTitle(presenter.doneButtonText, for: .normal)
        emailTextField.placeholder = presenter.emailPlaceholderText
    }
}

// MARK: - ForgotPasswordView

extension ForgotPasswordViewController: ForgotPasswordView {
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    func setEmail(text: String) {
        errorMessageLabel.text = text
    }
    
    func showErrors() {
        emailTextField.becomeFirstResponder()
        emailTextField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate

extension ForgotPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textField = textField as? SkyFloatingLabelTextField, let text = textField.text else {
            return
        }
        emailTextField.errorMessage = presenter.validate(email: text) ? presenter.emailPlaceholderText : ""
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setEmail(text: "")
        emailTextField.errorMessage = ""
    }
}
