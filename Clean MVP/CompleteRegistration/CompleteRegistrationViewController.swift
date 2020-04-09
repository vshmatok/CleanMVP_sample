import UIKit
import GooglePlaces

class CompleteRegistrationViewController: LoaderAlertViewController {
    
    // MARK: - Properties
    
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var completeButton: UIButton!
    private var autocompleteController: GMSAutocompleteViewController!
    var presenter: CompleteRegistrationPresenter!
    var configurator: CompleteRegistrationConfigurator!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configurate(controller: self)
        presenter.prepareUI()
        localizeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.removeObserver()
    }
    
    // MARK: - IBActions
    
    @IBAction private func completeRegistration(_ sender: UIButton) {
        presenter.didPressedCompleteRegistrationButton()
    }
    
    // MARK: - Private
    
    private func localizeUI() {
        navigationItem.title = presenter.navigationBarTitle
        completeButton.setTitle(presenter.completeButtonText, for: .normal)
    }
}

// MARK: - CompleteRegistrationView

extension CompleteRegistrationViewController: CompleteRegistrationView {
    
    func scrollToBottom() {
        tableView.scrollToRow(at: IndexPath(item: presenter.numberOfRows - 1, section: 0), at: .bottom, animated: false)
    }
    
    func reloadDataInCell(index: Int) {
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
    
    func setBottom(inset: CGFloat) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    func getIndexFor(cell: UITableViewCell) -> Int? {
        return tableView.indexPath(for: cell)?.row
    }
    
    func scrollTo(row: Int) {
        tableView.scrollToRow(at: IndexPath(item: row, section: 0), at: .middle, animated: false)
    }
    
    func getKyboardViewAt(index: Int) -> CompleteRegistrationBaseCellView? {
        return tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CompleteRegistrationBaseCellView
    }
    
    func showAutocompleteViewController() {
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func configureAutocompleteController() {
        GMSPlacesClient.provideAPIKey(Google.mapsApiKey)
        autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
    }
    
    func showMoreActionSheetWith(firstTitle: String, secondTitle: String, firstCompletion: @escaping () -> (), secondCompletion: @escaping () -> ()) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionFirst = UIAlertAction(title: firstTitle, style: .default) { (_) in
            firstCompletion()
        }
        actionFirst.setFont(color: UIColor.actionSheetBlack)
        let actionSecond = UIAlertAction(title: secondTitle, style: .default) { (_) in
            secondCompletion()
        }
        actionSecond.setFont(color: UIColor.actionSheetBlack)
        let actionCancel = UIAlertAction(title: presenter.cancelText, style: .cancel)
        actionCancel.setFont(color: UIColor.actionSheetOrange)
        alertController.addAction(actionFirst)
        alertController.addAction(actionSecond)
        alertController.addAction(actionCancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showPicker() {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.navigationBar.isTranslucent = false
        controller.navigationBar.barTintColor = UIColor(red: 29 / 255, green: 29 / 255, blue: 29 / 255, alpha: 1)
        controller.allowsEditing = false
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func registerCell(name: String, identifier: String) {
        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: identifier)
    }
    
    func updateTableView() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

// MARK: - UITableViewDataSource

extension CompleteRegistrationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = presenter.getCellIndentifierFor(index: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: indentifier)
        
        if let view = cell as? CompleteRegistrationBaseCellView {
            presenter.configurateCell(view: view, at: indexPath.row)
        }
        
        return cell!
    }
}

// MARK: - UITableViewDelegate

extension CompleteRegistrationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return presenter.getCellHeightFor(index: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension CompleteRegistrationViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            presenter.save(image: image)
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - GMSAutocompleteViewControllerDelegate

extension CompleteRegistrationViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        presenter.update(adress: place.formattedAddress ?? "")
        setBottom(inset: 0)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        showAlert(message: error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        setBottom(inset: 0)
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
