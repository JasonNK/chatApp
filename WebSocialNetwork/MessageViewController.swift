//
//  MessageViewController.swift
//  WebSocialNetwork
//
//  Created by Jason on 1/31/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit
import Firebase



class MessageViewController: UIViewController {

    @IBOutlet weak var messageTable: UITableView!
    var messages = [(String, String, String, String, UIImage)]() // time, messageid, oppoId, lastTxt, user profile
    let curUserId = Auth.auth().currentUser?.uid
    let databaseRef = Database.database().reference()
    let storageRef = Storage.storage().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        messageTable.dataSource = self
        messageTable.delegate = self
        // Do any additional setup after loading the view.
        let dispatchGroup = DispatchGroup()
        self.databaseRef.child("Messages/\(self.curUserId!)").observeSingleEvent(of: .value) { (dataSnapshot) in
            let data = dataSnapshot.value as? [String: [String: String]]
            guard let allMessages = data else {print("There is no message"); return}
            for (messageId, val) in allMessages {
                dispatchGroup.enter()
                let lastTime = val["lastTime"]!
                let lastMessage = val["lastMessage"]!
                let oppoId = val["oppoId"]!
                var img: UIImage?
                self.storageRef.child("User/\(oppoId)").getData(maxSize: 10000000) { (data, error) in
                    if error == nil {
                        if let data = data {
                            img = UIImage.init(data: data)
                        } else {
                            img = UIImage()
                        }
                        self.messages.append((lastTime, messageId, oppoId, lastMessage, img!))
                        dispatchGroup.leave()
                    } else {
                        print("error")
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    self.messageTable.reloadData()
                }
            }
        }
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

extension MessageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTable.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        cell.imageView?.image = self.messages[indexPath.row].4
        cell.textLabel?.text = self.messages[indexPath.row].3
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
        vc.oppoUserId = self.messages[indexPath.row].2
        vc.messageId = self.messages[indexPath.row].1
        vc.delegate = self
        vc.num = indexPath.row
        navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension MessageViewController: GetLatestMessageProtocol {

    
    func getLatest(message: String, num: Int) {
        self.messages[num] = (self.messages[num].0, self.messages[num].1, self.messages[num].2, message, self.messages[num].4)
        self.messageTable.reloadRows(at: [IndexPath.init(row: num, section: 0)], with: .automatic)
        
    }
    
    
}

