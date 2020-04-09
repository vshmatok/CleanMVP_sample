import UIKit

final class CategoriesViewController: LoaderAlertViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak fileprivate var selectPreferableCategoryLabel: UILabel!
    @IBOutlet weak fileprivate var categoriesCollectionView: UICollectionView!
    @IBOutlet weak fileprivate var pageControl: UIPageControl!
    @IBOutlet weak fileprivate var okButton: UIButton!
    @IBOutlet weak fileprivate var cancelButton: UIButton!
    
    fileprivate var configurator: CategoriesConfigurator = CategoriesConfiguratorImplementation()
    var presenter: CategoriesPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurator.configure(viewController: self)
        presenter.preparePresenter()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        presenter.router.prepare(for: segue, sender: sender)
        
        super.prepare(for: segue, sender: sender)
    }
    
    // MARK: - Actions
    
    @IBAction private func okButtonTapped(_ sender: UIButton) {
        presenter.updateCategories()
    }
    
    @IBAction private func cancelButtonTapped(_ sender: UIButton) {
        presenter.router.showStartScreen(completion: nil)
    }
    
    // MARK: - Private
    
    func configureCurrentPage() {
        let cellWidth = categoriesCollectionView.frame.width
        pageControl.currentPage = presenter.calculateCurrentPageFor(offset: categoriesCollectionView.contentOffset.x, andCellWidth: cellWidth)
    }
}

// MARK: - UICollectionViewDataSource

extension CategoriesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoriesCollectionViewCell.nibName, for: indexPath) as! CategoriesCollectionViewCell
        presenter.configure(view: cell, at: indexPath.item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfCategories
    }
    
}

// MARK: - UICollectionViewDelegate

extension CategoriesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)as! CategoriesCollectionViewCell
        presenter.didSelect(cell: cell, atIndex: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CategoriesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = presenter.calculateProportionalWidthFor(categoriesCollectionView.frame.width)
        let height = categoriesCollectionView.frame.height
        return CGSize(width: width, height: height)
    }
    
}

// MARK: - CategoriesViewProtocol

extension CategoriesViewController: CategoriesView {
    
    func reloadData() {
        categoriesCollectionView.reloadData()
        pageControl.numberOfPages = presenter.numberOfCategories
        configureCurrentPage()
    }
    
    func registerNibWith(name: String, forCellIdentifier identifier: String) {
        categoriesCollectionView.register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
    func localizeUI() {
        okButton.setTitle(presenter.okText, for: .normal)
        cancelButton.setTitle(presenter.cancelText, for: .normal)
        selectPreferableCategoryLabel.text = presenter.selectPreferableCategoriesText
    }
}

// MARK: - UIScrollViewDelegate

extension CategoriesViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        configureCurrentPage()
    }
}
