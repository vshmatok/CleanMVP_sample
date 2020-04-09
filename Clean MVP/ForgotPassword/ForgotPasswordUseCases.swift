import UIKit

protocol ForgotPasswordUseCases {
    
    func resetPassword(email: String, completion: @escaping ForgotPasswordHandler)
}

final class ForgotPasswordUseCasesImplementation: ForgotPasswordUseCases {
    
    // MARK: - Properties
    
    let gateway: ForgotPasswordGateway
    
    // MARK: - LifeCycle
    
    init(gateway: ForgotPasswordGateway) {
        self.gateway = gateway
    }
    
    // MARK: - ForgotPasswordUseCases
    
    func resetPassword(email: String, completion: @escaping ForgotPasswordHandler) {
        gateway.forgotPasswordFor(email: email, completion: completion)
    }
    
}
