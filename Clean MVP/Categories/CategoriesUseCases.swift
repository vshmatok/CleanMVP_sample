import Foundation

typealias CategoryComplection = (_ models: Result<(categories: [Category], count: Int)>) -> ()
typealias UserComplection = (_ models: Result<User>) -> ()

// MARK: - Protocols

protocol CategoriesUseCases {
    func categoriesList(fromPage page: Int?, perPage pages: Int?, completion: @escaping CategoryComplection)
    func updateUserPreferableCategories(_ preferableCategories: [Category], completion: @escaping UserComplection)
}

final class CategoriesUseCasesImplementation: CategoriesUseCases {
    
    // MARK: - Properties
    
    let categoriesGateway: CategoriesGateway
    let userGateway: UserGateway
    
    // MARK: - LifeCycle
    
    init(categoriesGateway: CategoriesGateway, userGateway: UserGateway) {
        self.categoriesGateway = categoriesGateway
        self.userGateway = userGateway
    }
    
    // MARK: - CategoriesUseCases
    
    func categoriesList(fromPage page: Int?, perPage pages: Int?, completion: @escaping CategoryComplection) {
        categoriesGateway.getCategoriesList(fromPage: page, perPage: pages, isIncludeToCollectCategory: true) { [weak self] (result) in
            self?.handle(result: result, completion: completion)
        }
    }
    
    func updateUserPreferableCategories(_ preferableCategories: [Category], completion: @escaping UserComplection) {
        let preferableCategoriesIds = preferableCategories.compactMap { $0.id }
        userGateway.updateUserProfile(categoryIds: preferableCategoriesIds) { [weak self] (result) in
            self?.handle(result: result, completion: completion)
        }
    }
    
    // MARK: - Private
    
    private func handle(result: Result<CategoriesModel>, completion: @escaping CategoryComplection) {
        switch result {
        case let .success(response):
            let categories = response.categories.map { return $0.category }
            let sortedCategories = categories.sorted(by: { $0.position < $1.position })
            let count = response.count
            let resultReturn = (sortedCategories, count!)
            completion(.success(resultReturn))
        case let .failure(error):
            completion(.failure(error))
        }
    }
    
    private func handle(result: Result<UserApiModel>, completion: @escaping UserComplection) {
        switch result {
        case let .success(response):
            completion(.success(response.user))
        case let .failure(error):
            completion(.failure(error))
        }
    }
    
}
