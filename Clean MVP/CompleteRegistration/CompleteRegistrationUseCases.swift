import UIKit

// MARK: - Protocol

protocol CompleteRegistrationUseCases: class {
    func createAccount(parameters: UserParameters, compleion: @escaping SignInCompletion)
    func saveUserProfileFrom(parameters: UserParameters, sessionToken: String, comepltion: @escaping UserCompletionHandler)
    func getDataSourceForSocial(_ social: Bool, userParameters: UserParameters) -> [CompleteRegistrationCellModel]
}

final class CompleteRegistrationUseCasesImplementation: CompleteRegistrationUseCases {
    
    // MARK: - Properties
    
    let gateway: RegistrationGateway
    let userGateway: UserGateway
    
    // MARK: - LifeCycle
    
    init(gateway: RegistrationGateway, userGateway: UserGateway) {
        self.gateway = gateway
        self.userGateway = userGateway
    }
    
    // MARK: - CreateProfileUseCases
    
    func getDataSourceForSocial(_ social: Bool, userParameters: UserParameters) -> [CompleteRegistrationCellModel] {
        if social {
            return [ImageRegistrationCellModel(userParameters: userParameters),
                    TextFieldRegistrationCellModel(cellType: .fullName, placeholder: "CompleteRegistration.fullName".localized + "*", userParameters: userParameters),
                    TextFieldRegistrationCellModel(cellType: .email, placeholder: "CompleteRegistration.email".localized + "*", userParameters: userParameters),
                    BioRegistrationCellModel(placeholder: "CompleteRegistration.bio".localized + "*", userParameters: userParameters),
                    TextFieldRegistrationCellModel(cellType: .address, placeholder: "CompleteRegistration.location".localized, userParameters: userParameters)]
        } else {
            return [ImageRegistrationCellModel(userParameters: userParameters),
                    TextFieldRegistrationCellModel(cellType: .fullName, placeholder: "CompleteRegistration.fullName".localized + "*", userParameters: userParameters),
                    BioRegistrationCellModel(placeholder: "CompleteRegistration.bio".localized + "*", userParameters: userParameters),
                    TextFieldRegistrationCellModel(cellType: .address, placeholder: "CompleteRegistration.location".localized, userParameters: userParameters)]
        }
    }
        
    func createAccount(parameters: UserParameters, compleion: @escaping SignInCompletion) {
        gateway.create(profile: parameters) { (result) in
            switch result {
            case let .success(response):
                let token: String = response.token
                let user: User = response.model.user
                let isSocial: Bool = false
                let resultToReturn = (user, token, isSocial)
                compleion(.success(resultToReturn))
            case let .failure(error):
                compleion(.failure(error))
            }
        }
    }
    
    func saveUserProfileFrom(parameters: UserParameters, sessionToken: String, comepltion: @escaping UserCompletionHandler) {
        let group: DispatchGroup = DispatchGroup()
        var responseError: Error?
        var profileResponse: UserApiModel?
        var profileResponseImageUrl: String?
        if let image = parameters.userImage, let imageData = UIImageJPEGRepresentation(image, 0.2) {
            group.enter()
            userGateway.updateUserProfileForRegistration(imageData: imageData, sessionToken: sessionToken) { (result) in
                switch result {
                case let .success(response):
                    profileResponseImageUrl = response.profileImageUrl
                case let .failure(error):
                    responseError = error
                }
                group.leave()
            }
        }
        
        group.enter()
        userGateway.updateUserProfileForRegistration(parameters: parameters, sessionToken: sessionToken) { (result) in
            switch result {
            case let .success(response):
                profileResponse = response
            case let .failure(error):
                responseError = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let error = responseError {
                comepltion(.failure(error))
            } else if var response = profileResponse {
                if let profileResponseImageUrl = profileResponseImageUrl {
                    response.profileImageUrl = profileResponseImageUrl
                }
                comepltion(.success(response))
            } else {
                comepltion(.failure(NSError.unknownError))
            }
        }
    }
}
