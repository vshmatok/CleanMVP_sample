import Foundation

// MARK: - Protocol

protocol SignInWithEmailConfigurator: class {
    func configurate(controller: SignInWithEmailViewController)
}

final class SignInWithEmailConfiguratorImplementation: SignInWithEmailConfigurator {
    
    // MARK: - Public
    
    func configurate(controller: SignInWithEmailViewController) {
        let apiClient: ApiClient = ApiClientImplementation.defaultConfiguration
        let gateway: LoginGateway = LoginGatewayImplementation(apiClient: apiClient)
        let useCases: SignInWithEmailUseCases = SignInWithEmailUseCasesImplementation(gateway: gateway)
        let router: SignInWithEmailRouter = SignInWithEmailRouterImplementation(controller: controller)
        let presenter: SignInWithEmailPresenter = SignInWithEmailPresenterImplementation(view: controller, router: router, useCases: useCases)
        
        controller.presenter = presenter
    }
}
