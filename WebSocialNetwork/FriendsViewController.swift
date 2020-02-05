//
//  FriendsViewController.swift
//  WebSocialNetwork
//
//  Created by Jason on 1/30/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableV: UITableView!
    let databaseRef = Database.database().reference()
    let storageRef = Storage.storage().reference()
    var curUserId = Auth.auth().currentUser?.uid
    var friends: [(String, String, UIImage)] = []
    let listDispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableV.delegate = self
        tableV.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var results = [(String, String, UIImage)]()
        // TODO Friends
        databaseRef.child("Friends").child(curUserId!).observeSingleEvent(of: .value) { [unowned self] (dataSnapshot) in
            self.listDispatchGroup.enter()
            let allFriends = dataSnapshot.value as? [String: String] ?? [:]
            if allFriends.count == 0 {self.listDispatchGroup.leave()}
            for friendUserId in allFriends.keys.sorted() {
                self.databaseRef.child("User").child(friendUserId).observeSingleEvent(of: .value) { (dataSnapshot) in
                    let friendData = dataSnapshot.value as? [String: Any] ?? [:]
                    // get first name
                    let firstName = (friendData["FirstName"] as? String) ?? ""
                    // get pic
                    self.storageRef.child("User").child(friendUserId).getData(maxSize: 10000000) { (data, error) in
                        var uiImage: UIImage
                        if let data = data {
                            uiImage = UIImage.init(data: data)!
                        } else {
                            uiImage = UIImage()
                        }
                        results.append((friendUserId, firstName, uiImage))
                        self.listDispatchGroup.leave()
                    }
                }
                
            }
            self.listDispatchGroup.notify(queue: .main) {
                self.friends = results
                self.tableV.reloadData()
            }
            
            
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableV.dequeueReusableCell(withIdentifier: "friendTableCell")
        let data = self.friends[indexPath.row]
        cell?.imageView?.image = data.2
        cell?.imageView?.layer.cornerRadius = (cell?.imageView?.frame.size.height ?? 0) / 2
        cell?.imageView?.clipsToBounds = true
        cell?.textLabel?.text = data.1
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
        let data = self.friends[indexPath.row]
        vc.oppoUserId = data.0
        
        navigationController?.pushViewController(vc, animated: true)
    }


}
