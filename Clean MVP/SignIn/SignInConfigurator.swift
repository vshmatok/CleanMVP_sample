import Foundation

// MARK: - Protocols

protocol SignInConfigurator: class {
    func configure(controller: SignInViewController)
}

final class SignInConfiguratorImplementation: SignInConfigurator {
    
    // MARK: - Public
    
    func configure(controller: SignInViewController) {
        let apiClient: ApiClient = ApiClientImplementation.defaultConfiguration
        let gateway: LoginGateway = LoginGatewayImplementation(apiClient: apiClient)
        let categoriesGateway: CategoriesGateway = CategoriesGatewayImplementation(apiClient: apiClient)
        let useCases: SignInUseCases = SignInUseCasesImplementation(gateway: gateway, categoriesGateway: categoriesGateway)
        let router: SignInRouter = SignInRouterImplementation(controller: controller)
        let socialServices: SocialServices = SocialServices(forViewController: controller)
        let presenter: SignInPresenter = SignInPresenterImplementation(view: controller, useCases: useCases, router: router, socialService: socialServices)
        
        controller.presenter = presenter
    }
    
}
