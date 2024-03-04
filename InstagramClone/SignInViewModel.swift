//
//  FeedViewModel.swift
//  SocialVideoApp
//
//  Created by MA1424 on 29/02/24.
//

import Foundation

protocol SignInViewModelDelegate: AnyObject {
    func signInDidSucceed()
    func signInDidFail(with error: Error)
}

class SignInViewModel {
    
    weak var delegate: SignInViewModelDelegate?
    
    func signIn(with credentials: UserCredentials) {
      FireBaseStore.login(withEmail: credentials.email, password: credentials.password) { [weak self] error in
        guard let self = self else { return }
        if let error = error {
          self.delegate?.signInDidFail(with: error)
          return
        }
        self.delegate?.signInDidSucceed()
      }
    }
}
