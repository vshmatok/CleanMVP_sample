import UIKit

protocol ResetPasswordUseCases {
    func resetPassword(resetToken: String, newPassword: String, completion: @escaping ForgotPasswordHandler)
}

final class ResetPasswordUseCasesImplementation: ResetPasswordUseCases {
    
    // MARK: - Properties
    
    let gateway: ForgotPasswordGateway
    
    // MARK: - LifeCycle
    
    init(gateway: ForgotPasswordGateway) {
        self.gateway = gateway
    }
    
    // MARK: - ResetPasswordUseCases
    
    func resetPassword(resetToken: String, newPassword: String, completion: @escaping ForgotPasswordHandler) {
        gateway.restorePassword(resetToken: resetToken, newPassword: newPassword, completion: completion)
    }
}
