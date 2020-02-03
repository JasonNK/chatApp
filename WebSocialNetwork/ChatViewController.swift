//
//  ChatViewController.swift
//  WebSocialNetwork
//
//  Created by Jason on 1/30/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit
import Firebase

protocol GetLatestMessageProtocol {
    
    func getLatest(message: String, num: Int)
}

class ChatViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textV: UITextView!
    var chats = [(String, String)]()
    lazy var curUserId = Auth.auth().currentUser?.uid
    var oppoUserId: String?
    var messageId: String?
    let databaseRef = Database.database().reference()
    var delegate: GetLatestMessageProtocol?
    var num = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        guard let curUserId = self.curUserId, let oppoUserId = self.oppoUserId else {
            print("error no user ids")
            return
        }

        let temp = [curUserId, oppoUserId].sorted {(a, b) in a < b}
        self.messageId = "\(temp.first!),\(temp.last!)"
        // fetch all chats
        // if there is chats
        // Todo remove the unnessary !
//        self.databaseRef.child("Chats").child(self.messageId!).observe(<#T##eventType: DataEventType##DataEventType#>, with: <#T##(DataSnapshot) -> Void#>)
        self.databaseRef.child("Chats").child(self.messageId!).observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let curChats = dataSnapshot.value as? [String: [String: String]] else { print("No chats"); return }
            
            for chatKey in curChats.keys.sorted() {
                self.chats.append((curChats[chatKey]?["text"] ?? "", curChats[chatKey]?["recId"] ?? ""))
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.collectionView.scrollToItem(at: IndexPath.init(row: self.chats.count - 1, section: 0), at: .bottom , animated: true)
            }
            

        }
        
        
    }
    
    
    
    
    @IBAction func sendText(_ sender: Any) {
        
        if self.chats.count == 0 {
            // if this is the first time send txt
            // 1. generate message item for both user
            self.databaseRef.child("Messages/\(self.curUserId!)/\(self.messageId!)").setValue(self.oppoUserId!)
            self.databaseRef.child("Messages/\(self.oppoUserId!)/\(self.messageId!)").setValue(self.curUserId!)
            
        }
        // generate chat item
        
        let timestamp = (Date().timeIntervalSince1970 * 1000.0).rounded()
        
        self.databaseRef.child("Chats/\(self.messageId!)/\(Int64(timestamp))").setValue(["text": textV.text, "recId": self.oppoUserId]) { (error, dataRef) in
            if error == nil {
                self.databaseRef.child("Messages/\(self.curUserId!)/\(self.messageId!)").setValue(["lastTime": "\(Int64(timestamp))", "oppoId": self.oppoUserId!, "lastMessage": self.textV.text ?? ""])
                self.databaseRef.child("Messages/\(self.oppoUserId!)/\(self.messageId!)").setValue(["lastTime": "\(Int64(timestamp))", "oppoId": self.curUserId!, "lastMessage": self.textV.text ?? ""])
                
                self.chats.append((self.textV.text, self.oppoUserId!))
                // TODO to be understood
                let newIndexPath = IndexPath.init(row: self.chats.count - 1, section: 0)
                
//                    self.collectionView.performBatchUpdates({ () -> Void in
//                        self.collectionView.insertItems(at: [newIndexPath])
//                    })
                    // self.collectionView.scrollToItem(at: newIndexPath, at: .bottom , animated: true)
                DispatchQueue.main.async {
                    self.collectionView.insertItems(at: [newIndexPath])
                    self.collectionView.reloadData()
                    self.collectionView.scrollToItem(at: newIndexPath, at: .bottom , animated: true)
                }
                
            
            } else {
                print("error insert chat")
            }
        }
            
            
        
        
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        if let lastMessageItem = self.chats.last {
            self.delegate?.getLatest(message: lastMessageItem.0, num: self.num)
        }
    }

    
    
    
}

extension ChatViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        chats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "chatCollectionViewCell", for: indexPath) as! CustomChatCollectionViewCell
        cell.meView.isHidden = true
        cell.oppoView.isHidden = true
        let curChat = self.chats[indexPath.row]
        
        if curChat.1 == self.curUserId {
            // TODO: unsolved mystery of isHidden property
            cell.oppoView.isHidden = false
            cell.oppoLabel.text = curChat.0
        } else {
            
            cell.meView.isHidden = false
            cell.meLabel.text = curChat.0
        }
        return cell
    }
//
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

//            var collectionViewSize = collectionView.frame.size
//            collectionViewSize.width = collectionViewSize.width / 1.3 //Display Three elements in a row.
//            // collectionViewSize.height = collectionViewSize.height / 6
//        return CGSize.init(width: collectionViewSize.width, height: 1)
//
        
         let item = chats[indexPath.row].0
         let itemSize = item.size(withAttributes: [
             NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)
         ])
        
        
        let desiredWidth = min(collectionView.contentSize.width / 1.3, itemSize.width)
        var desiredHeight: CGFloat = itemSize.height * 3
        if itemSize.width > desiredWidth {
            desiredHeight = itemSize.height * (itemSize.width / desiredWidth ) * 3
        }
        print(desiredHeight)
        return CGSize(width: collectionView.contentSize.width / 1.3, height: desiredHeight)
    }
    
}
