import UIKit

class RestorePasswordViewController: LoaderAlertViewController {
    
    // MARK: - Properties
    
    @IBOutlet private weak var confirmPasswordErrorLabel: UILabel!
    @IBOutlet private weak var confirmPasswordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet private weak var newPasswordErrorLabel: UILabel!
    @IBOutlet private weak var newPasswordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet private weak var completeRestorationButton: UIButton!
    var presenter: RestorePasswordPresenter!
    var configurator: RestorePasswordConfigurator!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(viewController: self)
        localizeUI()
    }

    // MARK: - IBActions
    
    @IBAction private func didTappedOnView(_ sender: UITapGestureRecognizer) {
        hideKeyboard()
    }
    
    @IBAction private func didTappedCompleteButton(_ sender: UIButton) {
        guard let password = newPasswordTextField.text, let confirmPassword = confirmPasswordTextField.text else {
            return
        }
        presenter.resetPasswordWith(password: password, confirmationPassword: confirmPassword)
    }
    
    // MARK: - Private
    
    private func localizeUI() {
        title = presenter.titleText
        confirmPasswordTextField.placeholder = presenter.confirmPasswordPlaceholder
        newPasswordTextField.placeholder = presenter.passwordPlaceholder
        completeRestorationButton.setTitle(presenter.confirmButtonPasswordText, for: .normal)
    }
}

// MARK: - ResporePasswordView

extension RestorePasswordViewController: ResporePasswordView {
    
    func setPassword(error: String) {
        newPasswordErrorLabel.text = error
    }
    
    func setConfirmPassword(error: String) {
        confirmPasswordErrorLabel.text = error
    }
    
    func showErrors() {
        confirmPasswordTextField.becomeFirstResponder()
        newPasswordTextField.becomeFirstResponder()
        newPasswordTextField.resignFirstResponder()
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension RestorePasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == newPasswordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else {
            hideKeyboard()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textField = textField as? SkyFloatingLabelTextField, let text = textField.text else {
            return
        }
        if textField == newPasswordTextField {
            newPasswordTextField.errorMessage = presenter.validate(password: text) ? presenter.passwordPlaceholder : ""
        } else {
            confirmPasswordTextField.errorMessage = presenter.validate(confirmPassword: text) ? presenter.confirmPasswordPlaceholder : ""
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == newPasswordTextField {
            newPasswordTextField.errorMessage = ""
            setPassword(error: "")
        } else {
            confirmPasswordTextField.errorMessage = ""
            setConfirmPassword(error: "")
        }
    }
}
