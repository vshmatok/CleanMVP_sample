import UIKit

// MARK: - Protocol

protocol CompleteRegistrationConfigurator: class {
    func configurate(controller: CompleteRegistrationViewController)
}

final class CompleteRegistrationConfiguratorImplementation: CompleteRegistrationConfigurator {
    
    // MARK: - Properties
    
    private var userParameters: UserParameters
    
    // MARK: - Configurations
    
    init(userParameters: UserParameters) {
        self.userParameters = userParameters
    }
    
    // MARK: - Public
    
    func configurate(controller: CompleteRegistrationViewController) {
        let apiClient: ApiClient = ApiClientImplementation.defaultConfiguration
        let userGateway: UserGateway = UserGatewayImplementation(apiClient: apiClient)
        let registrationGateway: RegistrationGateway = RegistrationGatewayImplementation(apiClient: apiClient)
        let useCases: CompleteRegistrationUseCases = CompleteRegistrationUseCasesImplementation(gateway: registrationGateway, userGateway: userGateway)
        let router: CompleteRegistrationRouter = CompleteRegistrationRouterImplementation(controller: controller)
        let presenter: CompleteRegistrationPresenter = CompleteRegistrationPresenterImplementaion(view: controller, useCases: useCases, router: router, userParameters: userParameters)
        controller.presenter = presenter
    }
}
