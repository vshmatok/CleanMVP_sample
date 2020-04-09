import UIKit

// MARK: - Protocols

protocol CompleteRegistrationBaseCellPresenter: class {
    var delegate: CompleteRegistrationCellDelegate? { get set }
    func configurateCellWith(model: CompleteRegistrationCellModel)
}

protocol CompleteRegistrationBaseCellView: class {
    var delegate: CompleteRegistrationCellDelegate? { get set }
    var basePresenter: CompleteRegistrationBaseCellPresenter { get }
    func becomeFirstResponder(silent: Bool)
}

protocol CompleteRegistrationCellDelegate: class {
    func didTappedOnImage()
    func updateTableView()
    func openLocationFinder()
    func getIndexFor(cell: UITableViewCell) -> Int?
    func returnKeyTappedForCellAt(index: Int)
    func didSelectCellAt(index: Int)
}

protocol CompleteRegistrationView: BaseView {
    func showMoreActionSheetWith(firstTitle: String, secondTitle: String, firstCompletion: @escaping () -> (), secondCompletion: @escaping () -> ())
    func showPicker()
    func showAutocompleteViewController()
    func configureAutocompleteController()
    func reloadDataInCell(index: Int)
    func registerCell(name: String, identifier: String)
    func updateTableView()
    func hideKeyboard()
    func getIndexFor(cell: UITableViewCell) -> Int?
    func getKyboardViewAt(index: Int) -> CompleteRegistrationBaseCellView?
    func setBottom(inset: CGFloat)
    func scrollTo(row: Int)
    func scrollToBottom()
}

protocol CompleteRegistrationPresenter: class {
    var router: CompleteRegistrationRouter { get }
    var completeButtonText: String { get }
    var navigationBarTitle: String { get }
    var cancelText: String { get }
    var numberOfRows: Int { get }
    func addKeyboardObserver()
    func removeObserver()
    func prepareUI()
    func configurateCell(view: CompleteRegistrationBaseCellView, at index: Int)
    func getCellIndentifierFor(index: Int) -> String
    func getCellHeightFor(index: Int) -> CGFloat
    func save(image: UIImage)
    func update(adress: String)
    func didPressedCompleteRegistrationButton()
}

final class CompleteRegistrationPresenterImplementaion: CompleteRegistrationPresenter {
    
    // MARK: - Local constants
    
    private struct LocalConstants {
        static let distanceToBottom: CGFloat = 108
    }
    
    // MARK: - Properties
    
    var router: CompleteRegistrationRouter
    private var useCases: CompleteRegistrationUseCases
    private unowned var view: CompleteRegistrationView
    private var userParameters: UserParameters
    private var dataSource: [CompleteRegistrationCellModel] = []
    var numberOfRows: Int {
        return dataSource.count
    }
    var navigationBarTitle: String {
        return "CompleteRegistration.navigationBar.title".localized
    }
    var completeButtonText: String {
        return "ForgotPassword.nextButton".localized
    }
    var cancelText: String {
        return "Alert.cancel".localized
    }
    
    // MARK: - Configurations
    
    init(view: CompleteRegistrationView, useCases: CompleteRegistrationUseCases, router: CompleteRegistrationRouter, userParameters: UserParameters) {
        self.view = view
        self.userParameters = userParameters
        self.useCases = useCases
        self.router = router
    }
    
    // MARK: - Public
    
    func prepareUI() {
        view.registerCell(name: BioCompleteRegistrationTableViewCell.nibName, identifier: BioCompleteRegistrationTableViewCell.nibName)
        view.registerCell(name: ImageCompleteRegistrationTableViewCell.nibName, identifier: ImageCompleteRegistrationTableViewCell.nibName)
        view.registerCell(name: TextFieldCompleteRegistrationTableViewCell.nibName, identifier: TextFieldCompleteRegistrationTableViewCell.nibName)
        dataSource = useCases.getDataSourceForSocial(userParameters.isFromSocial, userParameters: userParameters)
        view.configureAutocompleteController()
    }
    
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChangeFrame), name: .UIKeyboardWillHide, object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardChangeFrame(notification: NSNotification) {
        guard let keyboardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        if notification.name == .UIKeyboardWillHide {
            view.setBottom(inset: 0)
        } else {
            view.setBottom(inset: keyboardSize.size.height - LocalConstants.distanceToBottom)
        }
    }
    
    func configurateCell(view: CompleteRegistrationBaseCellView, at index: Int) {
        let model = dataSource[index]
        view.basePresenter.configurateCellWith(model: model)
        view.basePresenter.delegate = self
        view.delegate = self
    }
    
    func getCellIndentifierFor(index: Int) -> String {
        return dataSource[index].cellIdentifier
    }
    
    func getCellHeightFor(index: Int) -> CGFloat {
        return dataSource[index].cellHeight
    }
    
    func save(image: UIImage) {
        userParameters.userImage = image
        view.reloadDataInCell(index: 0)
    }
    
    func update(adress: String) {
        userParameters.address = adress
        dataSource.last?.errorMessage = ""
        view.reloadDataInCell(index: dataSource.count - 1)
    }
    
    func didPressedCompleteRegistrationButton() {
        guard isValidData() else {
            showErrors()
            return
        }
        view.showLoader()
        if userParameters.isFromSocial {
            useCases.saveUserProfileFrom(parameters: userParameters, sessionToken: userParameters.sessionToken) { [weak self] (result) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.view.hideLoader()
                switch result {
                case let .success(response):
                    var responseUser = response.user
                    responseUser.isLoginedFromSocials = true
                    strongSelf.save(token: strongSelf.userParameters.sessionToken)
                    strongSelf.save(user: responseUser)
                    if response.user.categoryIds.isEmpty {
                        strongSelf.router.showCategories()
                    } else {
                        strongSelf.router.openFeed()
                    }
                case let .failure(error):
                    strongSelf.view.alert(message: error.localizedDescription)
                }
            }
        } else {
            useCases.createAccount(parameters: userParameters) { [weak self] (result) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.view.hideLoader()
                switch result {
                case let .success(response):
                    var responseUser = response.user
                    responseUser.isLoginedFromSocials = response.isSocial
                    strongSelf.save(token: response.token)
                    strongSelf.save(user: responseUser)
                    if response.user.categoryIds.isEmpty {
                        strongSelf.router.showCategories()
                    } else {
                        strongSelf.router.openFeed()
                    }
                case let .failure(error):
                    strongSelf.view.alert(message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Private
    
    private func openActionSheet() {
        view.showMoreActionSheetWith(firstTitle: "CreatePost.container.takePhoto".localized,
                                     secondTitle: "CreatePost.container.galeryPhoto".localized,
                                     firstCompletion: { [weak self] in
            self?.router.openCamera(delegate: self)
        }, secondCompletion: {
            [weak self] in
            self?.view.showPicker()
        })
    }
    
    private func isValidData() -> Bool {
        if userParameters.fullName != "", userParameters.fullName.isValidName, userParameters.email != "", userParameters.email.isValidEmail, userParameters.bio != "" {
            return true
        } else {
            return false
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
    
    func showErrors() {
        view.scrollToBottom()
        UIView.setAnimationsEnabled(false)
        for index in 0...numberOfRows - 1 {
            if let view = self.view.getKyboardViewAt(index: index) {
                view.becomeFirstResponder(silent: true)
            }
        }
        UIView.setAnimationsEnabled(true)
    }
    
}

// MARK: - CompleteRegistrationCellDelegate

extension CompleteRegistrationPresenterImplementaion: CompleteRegistrationCellDelegate {
    
    func didTappedOnImage() {
        openActionSheet()
    }

    func updateTableView() {
        view.updateTableView()
    }
    
    func openLocationFinder() {
        view.showAutocompleteViewController()
    }
    
    func getIndexFor(cell: UITableViewCell) -> Int? {
        return view.getIndexFor(cell: cell)
    }
    
    func returnKeyTappedForCellAt(index: Int) {
        if index == dataSource.count - 1 {
            view.hideKeyboard()
        } else {
            let nextIndex = index + 1
            if let view = self.view.getKyboardViewAt(index: nextIndex) {
                view.becomeFirstResponder(silent: false)
                self.view.scrollTo(row: nextIndex)
            } else {
                returnKeyTappedForCellAt(index: nextIndex)
            }
        }
    }
    
    func didSelectCellAt(index: Int) {
        view.scrollTo(row: index)
    }
}

extension CompleteRegistrationPresenterImplementaion: CreateCameraPostPresenterDelegate {
    
    func sendPostVideoData(pathToFile: URL) {
    }
    
    func sendPostImageData(photoData: Data) {
        if let image = UIImage(data: photoData) {
            save(image: image)
        }
    }
    
}
