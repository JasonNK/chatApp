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
/**
 Warning: current design might cause the duplicate key in chatId since chatId is basically timestamp, even though it can be rarely happen
 we still recommend to append userId after the timestamp after generating key
 */

class ChatViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textV: UITextView!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var navTitle: UINavigationItem!
    
    
    var curUserId = Auth.auth().currentUser?.uid
    var oppoUserId: String?
    var messageId: String?
    let databaseRef = Database.database().reference()
    var num = 0
    let chatViewViewModel = ChatViewViewModel()
    
    fileprivate func listenForNewChat() -> Void {
        
        var firstLoad = true // fetch the last one when loading first
        self.databaseRef.child("Chats").child(self.messageId!).queryLimited(toLast: 1).observe(.childAdded) { (dataSnapshot) in
            // if there is at least one chat, preceed; else return
            if firstLoad {
                firstLoad.toggle()
                return
            }
            if let data = dataSnapshot.value as? [String: String] {
                
                if data["recId"] != self.curUserId {
                    // this is already added in the sendText
                } else {
                    self.fetchAllChats()
                }
            } else {
                print("No chat history.")
            }
        }
        
    }
    
    fileprivate func fetchAllChats() {
        // fetch all chats
        // if there is chats
        // Todo remove the unnessary !
        
        self.chatViewViewModel.fetchAllChats(messageId: self.messageId!) {  (arrTupleOp, errorOp) in
           if errorOp == nil {
               
               self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: IndexPath.init(row: self.chatViewViewModel.getChatsCount() - 1, section: 0), at: .bottom , animated: true)
           } else {
               // show error controller
           }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        textV.delegate = self
        guard let curUserId = self.curUserId, let oppoUserId = self.oppoUserId else {
            print("error no user ids")
            return
        }
        
        let temp = [curUserId, oppoUserId].sorted {(a, b) in a < b}
        self.messageId = "\(temp.first!),\(temp.last!)"
        
        
        listenForNewChat()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
//        chatViewViewModel.fetchAllChats(messageId: self.messageId!) { ([(String, String)]?, Error?) in
//
//        }
        fetchAllChats()
        self.tabBarController?.tabBar.isHidden = true
        self.btn.isEnabled = false
        self.textV.text = ""
        self.databaseRef.child("User/\(oppoUserId!)").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let data = dataSnapshot.value as? [String: Any] else {return}
            self.navTitle.title = data["FirstName"] as? String
        }
       
        
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    
    @IBAction func sendText(_ sender: Any) {
        
        if self.chatViewViewModel.getChatsCount() == 0 {
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
                
//                self.chats.append((self.textV.text, self.oppoUserId!))
//                // TODO to be understood
//                let newIndexPath = IndexPath.init(row: self.chats.count - 1, section: 0)
//                self.collectionView.insertItems(at: [newIndexPath])
//                self.collectionView.scrollToItem(at: newIndexPath, at: .bottom , animated: true)
                self.fetchAllChats()
                self.textV.text = ""
            } else {
                print("error insert chat")
            }
        }

    }
    

}

extension ChatViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.chatViewViewModel.getChatsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "chatCollectionViewCell", for: indexPath) as! CustomChatCollectionViewCell
        do {
            guard let curChat = try self.chatViewViewModel.getChatObject(index: indexPath.row) else {
                return cell
            }
            cell.setUpCellData(recId: curChat.1, contentTxt: curChat.0, curUserId: self.curUserId!)
        } catch {
            print("error")
            return cell
        }
        
        return cell
    }

    
    
}



extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let str = try! self.chatViewViewModel.getChatObject(index: indexPath.row)?.0 as! String
            
            
         let itemSize = str.size(withAttributes: [
             NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)
         ])
        
        
        let desiredWidth = min(collectionView.contentSize.width / 1.3, itemSize.width)
        var desiredHeight: CGFloat = itemSize.height * 3
        if itemSize.width > desiredWidth {
            desiredHeight = itemSize.height * (itemSize.width / desiredWidth ) * 3
        }
        print(desiredHeight, self.chatViewViewModel.getChatsCount)
        return CGSize(width: collectionView.contentSize.width / 1.3, height: desiredHeight)
    }
}


extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let txt = self.textV.text, txt != "" { self.btn.isEnabled = true; return}
        else { self.btn.isEnabled = false; return }
    }
}


enum AppErrors: String, Error {
    case indexOutOfBound = "index out of bound"
}
