//
//  SignUpViewModel.swift
//  WebSocialNetwork
//
//  Created by Jason on 2/4/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import Foundation
import Firebase

protocol SignUpViewModelDelegate {
    func performSignUp(_ authResult: AuthDataResult?,_ error: Error?)
}

class SignUpViewModel {
    var delegate: SignUpViewModelDelegate?
    func performSignUp(username: String, password: String, email: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            self.delegate?.performSignUp(authResult, error)
        }
    }
}
