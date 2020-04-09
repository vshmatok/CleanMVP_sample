import Foundation

// MARK: - Protocols

protocol CategoriesConfigurator {
    func configure(viewController: CategoriesViewController)
}

final class CategoriesConfiguratorImplementation: CategoriesConfigurator {
    
    func configure(viewController: CategoriesViewController) {
        let apiClient = ApiClientImplementation.defaultConfiguration
        let categoryGateway = CategoriesGatewayImplementation(apiClient: apiClient)
        let userGateway = UserGatewayImplementation(apiClient: apiClient)
        let useCases = CategoriesUseCasesImplementation(categoriesGateway: categoryGateway,
                                                        userGateway: userGateway)
        let router = CategoriesRouterImplementation(viewController: viewController)
        
        let presenter = CategoriesPresenterImplementation(view: viewController,
                                                          useCases: useCases,
                                                          router: router)
        
        viewController.presenter = presenter
    }
    
}
