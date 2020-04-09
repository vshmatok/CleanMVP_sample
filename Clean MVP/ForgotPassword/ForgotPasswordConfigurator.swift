import UIKit

protocol ForgotPasswordConfigurator {
    
    func configure(viewController: ForgotPasswordViewController)
}

final class ForgotPasswordConfiguratorImplementation: ForgotPasswordConfigurator {
    
    func configure(viewController: ForgotPasswordViewController) {
        let apiClient: ApiClient = ApiClientImplementation.defaultConfiguration
        let gateway: ForgotPasswordGateway = ForgotPasswordGatewayImplementation(apiClient: apiClient)
        let useCases: ForgotPasswordUseCases = ForgotPasswordUseCasesImplementation(gateway: gateway)
        let router: ForgotPasswordRouter = ForgotPasswordRouterImplementation(viewController: viewController)
        let presenter: ForgotPasswordPresenter = ForgotPasswordPresenterImplementation(view: viewController, userCases: useCases, router: router)
        viewController.presenter = presenter
    }
}
