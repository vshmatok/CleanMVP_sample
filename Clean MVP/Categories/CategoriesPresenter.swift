import UIKit

// MARK: - Protocols

protocol CategoriesPresenter {
    var numberOfCategories: Int { get }
    var router: CategoriesRouter { get }
    var okText: String { get }
    var cancelText: String { get }
    var selectPreferableCategoriesText: String { get }
    func preparePresenter()
    func updateCategories()
    func configure(view: CategoriesCollectionViewCell, at index: Int)
    func calculateProportionalWidthFor(_ value: CGFloat) -> CGFloat
    func calculateCurrentPageFor(offset: CGFloat, andCellWidth cellWidth: CGFloat) -> Int
    func didSelect(cell: CategoriesCollectionViewCell, atIndex index: Int)
}

protocol CategoriesView: BaseView {
    func reloadData()
    func registerNibWith(name: String, forCellIdentifier identifier: String)
    func localizeUI()
}

// MARK: - Constants

private struct CategoriesPresenterConstants {
    static let cellWidthProportionalNumber: CGFloat = 1.5625
}

// MARK: - CategoriesPresenterImplementation

final class CategoriesPresenterImplementation: CategoriesPresenter {
    
    // MARK: - Properties
    
    private unowned var view: CategoriesView
    private let useCases: CategoriesUseCases
    internal let router: CategoriesRouter
    
    private var categories: [Category] = []
    private var categoriesCount: Int = 0

    var numberOfCategories: Int {
        return categories.count
    }
    
    var okText: String {
        return "Categories.ok".localized
    }
    var cancelText: String {
        return "Categories.cancel".localized
    }
    var selectPreferableCategoriesText: String {
        return "Categories.selectPreferableCategories".localized
    }
    
    // MARK: - Lifecycle
    
    init(view: CategoriesView, useCases: CategoriesUseCases, router: CategoriesRouter & StartScreenRouter) {
        self.view = view
        self.useCases = useCases
        self.router = router
    }
    
    // MARK: - Public
    
    func preparePresenter() {
        view.registerNibWith(name: CategoriesCollectionViewCell.nibName, forCellIdentifier: CategoriesCollectionViewCell.nibName)
        view.localizeUI()
        loadModels()
    }
    
    func updateCategories() {
        let preferableCategories = categories.filter { $0.isSelected }
        if preferableCategories.isEmpty {
            view.alert(message: "Categories.select".localized)
            return
        }
        view.showLoader()
        useCases.updateUserPreferableCategories(preferableCategories) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.view.hideLoader()
            switch result {
            case let .success(response):
                UserService().save(user: response)
                strongSelf.router.showFeed()
            case let .failure(error):
                if let error = error as? HTTPError, error.statusCode == HTTPErrorCodes.unauthorized {
                    strongSelf.router.showStartScreen(completion: { presenter in
                        presenter.show(message: error.localizedDescription)
                    })
                } else {
                    strongSelf.view.alert(message: error.localizedDescription)
                }
            }
        }
    }
    
    func configure(view: CategoriesCollectionViewCell, at index: Int) {
        let model = categories[index]
        view.presenter.configureWith(model: model)
    }
    
    func didSelect(cell: CategoriesCollectionViewCell, atIndex index: Int) {
        guard index != 0 else {
            return
        }
        categories[index].isSelected.toggle()
        cell.set(selected: categories[index].isSelected)
    }
    
    func calculateProportionalWidthFor(_ value: CGFloat) -> CGFloat {
        return value / CategoriesPresenterConstants.cellWidthProportionalNumber
    }
    
    func calculateCurrentPageFor(offset: CGFloat, andCellWidth cellWidth: CGFloat) -> Int {
        let proportionalCellWidth = calculateProportionalWidthFor(cellWidth)
        let pageNumber = round(offset / proportionalCellWidth)
        return Int(pageNumber)
    }
    
    // MARK: - Private
    
    private func loadModels() {
        view.showLoader()
        useCases.categoriesList(fromPage: nil, perPage: nil) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.view.hideLoader()
            switch result {
            case let .success(respone):
                strongSelf.categories = respone.categories
                strongSelf.categories[0].isSelected = true
                strongSelf.categoriesCount = respone.count
                strongSelf.view.reloadData()
            case let .failure(error):
                strongSelf.view.alert(message: error.localizedDescription)
            }
        }
    }
}
