//
//  EditProfileViewController.swift
//  WebSocialNetwork
//
//  Created by Jason on 1/29/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imgeV: UIImageView!
    
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var addressTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    
    let imagePicker = UIImagePickerController()
    let databaseRef = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    var curUserId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let curUser = Auth.auth().currentUser else {print("please log in first"); return }
        curUserId = curUser.uid
        // get all the user's info from firebase
    databaseRef.child("User").child(curUser.uid).observeSingleEvent(of: .value) { (dataSnapshot) in
        let curUserData = dataSnapshot.value as! [String:Any]
        self.firstNameTxt.text = curUserData["FirstName"] as! String
        self.lastNameTxt.text = curUserData["LastName"] as! String
        self.addressTxt.text = curUserData["Address"] as! String
        self.phoneTxt.text = curUserData["Phone"] as! String
        
        self.storageRef.child("User").child(self.curUserId).getData(maxSize: 10000000) { (data, error) in
            guard let imageData = data else {print("user has no old photo"); return}
            self.imgeV.image = UIImage.init(data: imageData)
            }
        }
        // set up image picker
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.allowsEditing = true
    }
    
    @IBAction func setImg(_ sender: Any) {
        present(self.imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func submitProfile(_ sender: Any) {
        let firstName = firstNameTxt.text ?? ""
        let lastName = lastNameTxt.text ?? ""
        let phone = phoneTxt.text ?? ""
        let address = addressTxt.text ?? ""
        let image = imgeV.image?.jpegData(compressionQuality: 1.0) ?? Data()
        
        storageRef.child("User").child(curUserId).putData(image, metadata: StorageMetadata.init(dictionary: ["contentType": "image/jpeg"])) { (storageMetadata, error) in
            if error == nil {
                self.databaseRef.child("User").child(self.curUserId).setValue(["FirstName": firstName, "LastName": lastName, "Phone": phone, "Address": address]) { (error, dataRef) in
                    if error == nil {
                        print("set data successfully")
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        print("error in saving the user's data")
                    }
                }
            } else {
                print("error occur when storing the data to storage")
            }
        }
        
        
        
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let fetchedImage = info[.editedImage] as? UIImage else {
            return
        }
        
        imgeV.image = fetchedImage
        self.imagePicker.dismiss(animated: true, completion: nil)
        
    }

}


