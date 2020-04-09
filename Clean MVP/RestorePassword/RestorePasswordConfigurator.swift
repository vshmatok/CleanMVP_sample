import UIKit

protocol RestorePasswordConfigurator {
    func configure(viewController: RestorePasswordViewController)
}

final class RestorePasswordConfiguratorImplementation: RestorePasswordConfigurator {
    
    // MARK: - Properties
    
    private var resetToken: String
    
    // MARK: - Configurations
    
    init(resetToken: String) {
        self.resetToken = resetToken
    }
    
    // MARK: - Public
    
    func configure(viewController: RestorePasswordViewController) {
        let apiClient: ApiClient = ApiClientImplementation.defaultConfiguration
        let gateway: ForgotPasswordGateway = ForgotPasswordGatewayImplementation(apiClient: apiClient)
        let useCases: ResetPasswordUseCases = ResetPasswordUseCasesImplementation(gateway: gateway)
        let router: ResetPasswordRouter = ResetPasswordRouterImplementation(viewController: viewController)
        let presenter: RestorePasswordPresenter = RestorePasswordPresenterImplementation(view: viewController, userCases: useCases, router: router, resetToken: resetToken)
        viewController.presenter = presenter
    }
}
