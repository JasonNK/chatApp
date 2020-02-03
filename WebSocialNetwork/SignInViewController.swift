//
//  SignInViewController.swift
//  WebSocialNetwork
//
//  Created by Jason on 1/27/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let curUser = Auth.auth().currentUser else {
            return
        }
        let ctrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
        ctrl.modalPresentationStyle = .fullScreen
        self.present(ctrl, animated: true, completion: nil)
    }
    
    let databaseReference = Database.database().reference()
    
    
    @IBAction func signInAction(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: emailTxt.text ?? "", password: passwordTxt.text ?? "") { (authDataResult, error) in
            if error == nil {
                guard let currentUser = authDataResult?.user else {
                    return
                }
                let ctrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
                ctrl.modalPresentationStyle = .fullScreen
                self.present(ctrl, animated: true, completion: nil)
                
            } else {
                print("Password or email is wrong", error)
                
            }
        }
        
    }
    
    
    @IBAction func signUpAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SignUpViewController")
        navigationController?.pushViewController(vc!, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
