//
//  ViewController.swift
//  WebSocialNetwork
//
//  Created by Jason on 1/27/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var addressTxt: UITextField!
    
    let databaseReference = Database.database().reference()
    let signUpVM = SignUpViewModel()
    @IBAction func signUpAction(_ sender: UIButton) {
        guard let email = emailTxt.text, let firstname = firstNameTxt.text, let lastname = lastNameTxt.text, let password = passwordTxt.text, let phone = phoneTxt.text, let address = addressTxt.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [unowned self] (authDataResult, error) in
            if error == nil {
                guard let result = authDataResult?.user else { return }
                let userDict = ["FirstName": firstname, "Lastname": lastname, "Email": email, "Address": address, "Phone": phone] as [String : Any]
                self.databaseReference.child("User").child(result.uid).setValue(userDict) { (data, error) in
                    let st = UIStoryboard.init(name: "Main", bundle: nil)
                    let vc = st.instantiateViewController(identifier: "TabBarController")
                    self.navigationController?.pushViewController(vc, animated: true)
                }

            } else {
                print("something wrong when create user", error)
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

