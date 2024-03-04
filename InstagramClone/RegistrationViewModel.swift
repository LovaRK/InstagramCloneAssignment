//
//  FeedViewModel.swift
//  SocialVideoApp
//
//  Created by MA1424 on 29/02/24.
//

import UIKit

protocol RegistrationViewModelDelegate: AnyObject {
    func signUpDidSucceed()
    func signUpDidFail(with errorMessage: String)
}

class RegistrationViewModel {
    
    weak var delegate: RegistrationViewModelDelegate?
    weak var imagePickerDelegate: ImagePickerDelegate?
    
    // Inputs
    var email: String = ""
    var password: String = ""
    var userName: String = ""
    var profileImage: UIImage?
    
    // Outputs
    var errorMessage: String?
    
    func signUp() {
        // Perform validation
        guard !email.isEmpty, !password.isEmpty, !userName.isEmpty else {
            errorMessage = "Please fill in all fields."
            delegate?.signUpDidFail(with: errorMessage ?? "")
            return
        }
        
        // Use the ImagePicker to select the profile image
        guard let profileImage = profileImage else {
            errorMessage = "Please select a profile image."
            delegate?.signUpDidFail(with: errorMessage ?? "")
            return
        }

        // Perform sign up process
        FireBaseStore.createUser(email: email, password: password) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.delegate?.signUpDidFail(with: error.localizedDescription)
                return
            }
            
            guard let imageData = profileImage.jpeg(.medium) else {
                self?.errorMessage = "Failed to convert image to data."
                self?.delegate?.signUpDidFail(with: self?.errorMessage ?? "")
                return
            }
            
            FireBaseStore.updateProfileInfo(withImage: imageData, name: self?.userName ?? "") { [weak self] error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.delegate?.signUpDidFail(with: error.localizedDescription)
                    return
                }
                
                // Sign up successful
                self?.delegate?.signUpDidSucceed()
            }
        }
    }

    
    // Method to handle image selection
    func didSelectImage(_ image: UIImage?) {
        profileImage = image
    }
}
