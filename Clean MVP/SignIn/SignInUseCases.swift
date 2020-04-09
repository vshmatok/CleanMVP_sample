import Foundation
import UIKit

typealias SignInCompletion = (_ models: Result<(user: User, token: String, isSocial: Bool)>) -> ()
typealias CategoriesListCompletion = (Result<[Int]>) -> ()

protocol SignInUseCases {
    func facebookLogin(token: String, completion: @escaping SignInCompletion)
    func googleLogin(token: String, completion: @escaping SignInCompletion)
    func categoriesList(fromPage page: Int?, perPage pages: Int?, completion: @escaping CategoriesListCompletion)
}

final class SignInUseCasesImplementation: SignInUseCases {
    
    // MARK: - Properties
    
    let gateway: LoginGateway
    let categoriesGateway: CategoriesGateway
    
    // MARK: - LifeCycle
    
    init(gateway: LoginGateway, categoriesGateway: CategoriesGateway) {
        self.gateway = gateway
        self.categoriesGateway = categoriesGateway
    }
    
    // MARK: - LoginUseCases
    
    func categoriesList(fromPage page: Int?, perPage pages: Int?, completion: @escaping CategoriesListCompletion) {
        categoriesGateway.getCategoriesList(fromPage: page, perPage: pages, isIncludeToCollectCategory: false) { (result) in
            switch result {
            case let .success(response):
                let categories = response.categories.map { return $0.category.id }
                let resultReturn = (categories)
                completion(.success(resultReturn))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func facebookLogin(token: String, completion: @escaping SignInCompletion) {
        gateway.loginUserWithFacebook(token: token) { [weak self] (result) in
            self?.handle(result: result, isSocial: true, completion: completion)
        }
    }
    
    func googleLogin(token: String, completion: @escaping SignInCompletion) {
        gateway.loginUserWithGoogle(token: token) { [weak self] (result) in
            self?.handle(result: result, isSocial: true, completion: completion)
        }
    }
    
    // MARK: - Private
    
    private func handle(result: Result<LoginUserModel>, isSocial: Bool, completion: @escaping SignInCompletion) {
        switch result {
        case let .success(response):
            let user = response.model.user
            let token = response.token
            let resultReturn = (user, token, isSocial)
            completion(.success(resultReturn))
        case let .failure(error):
            completion(.failure(error))
        }
    }
}
