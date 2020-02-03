//
//  NewPostViewController.swift
//  WebSocialNetwork
//
//  Created by Jason on 1/27/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit
import Firebase

protocol PostDelegate {
    func postInfomation(img: UIImage, txt: String)
}


class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var contentTxt: UITextView!
    
    let imagePicker = UIImagePickerController.init()
    let databaseRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.allowsEditing = true
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func postAction(_ sender: Any) {
        
        let postId = databaseRef.child("Post").childByAutoId().key
        let curUser = Auth.auth().currentUser?.uid
        let data = ["userId": curUser, "desc": contentTxt.text ?? "", "time": "\(Date().timeIntervalSince1970)" ]
        databaseRef.child("Post").child(postId!).setValue(data) {
            [weak self] (error, dataRef) in
            guard let err = error else {
                // if err is nil then it is correct response
                let storageRef = Storage.storage().reference()
                storageRef.child("Feed").child(postId!).putData((self?.imageV.image?.jpegData(compressionQuality: 1))!, metadata: StorageMetadata.init(dictionary: ["contentType" : "image/jpeg"])) { (metadata, error) in
                    print("image save success!")
                    self?.navigationController?.popViewController(animated: true)
                }
                return
            }
            
        }
        
        //
        
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        // todo
        present(self.imagePicker, animated: true, completion: nil)
        
    }
    
    // todo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let fetchedImage = info[.editedImage] as? UIImage else {
            return
        }
        
        imageV.image = fetchedImage
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    
}


