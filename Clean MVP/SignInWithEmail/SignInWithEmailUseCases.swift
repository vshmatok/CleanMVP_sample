import UIKit

typealias LoginWithEmailCompletion = (_ models: Result<(user: User, token: String, isSocial: Bool)>) -> ()
typealias CheckEmailCompletion = (_ isCreated: Result<Bool>) -> ()

// MARK: - Protocol

protocol SignInWithEmailUseCases: class {
    func loginWith(email: String, password: String, completion: @escaping LoginWithEmailCompletion)
    func checkEmail(email: String, completion: @escaping CheckEmailCompletion)
    func cancelDownload()
}

final class SignInWithEmailUseCasesImplementation: SignInWithEmailUseCases {
    
    // MARK: - Properties
    
    let gateway: LoginGateway
    var dataTask: URLSessionDataTask?
    
    // MARK: - LifeCycle
    
    init(gateway: LoginGateway) {
        self.gateway = gateway
    }
    
    deinit {
        dataTask?.cancel()
    }
    
    // MARK: - Public
    
    func cancelDownload() {
        dataTask?.cancel()
    }
    
    func loginWith(email: String, password: String, completion: @escaping LoginWithEmailCompletion) {
        gateway.loginUserWith(email: email, password: password) { [weak self] (result) in
            self?.handle(result: result, isSocial: false, completion: completion)
        }
    }
    
    func checkEmail(email: String, completion: @escaping CheckEmailCompletion) {
        gateway.checkEmail(email: email,
                           dataTaskHandler: { [weak self] (dataTask) in
            self?.dataTask = dataTask
        },
                           completion: { (result) in
            switch result {
            case let .success(response):
                let isEmailCreated = response.isEmailCreated
                completion(.success(isEmailCreated))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }
    
    // MARK: - Private
    
    private func handle(result: Result<LoginUserModel>, isSocial: Bool, completion: @escaping LoginWithEmailCompletion) {
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
