//
//  FirebaseUtil.swift
//  WebSocialNetwork
//
//  Created by Jason on 2/4/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import Foundation
import Firebase

class FirebaseUtil {
    let databaseRef = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    private init() {}
    static let shared = FirebaseUtil()
    
    
    static func getUser() {
        
        
        
    }
    
    static func getFriends() {
        
    }
    
    static func getPosts() {
        
    }
    
    func fetchAllChats(messageId: String, completion: (([(String, String)]?, Error?)->Void)?) {
        
        self.databaseRef.child("Chats").child(messageId).observeSingleEvent(of: .value, andPreviousSiblingKeyWith: { (dataSnapshot, str) in
            
            guard let curChats = dataSnapshot.value as? [String: [String: String]] else { completion?(nil, nil); return }
                        var chats = [(String, String)]()
                        for chatKey in curChats.keys.sorted() {
                            chats.append((curChats[chatKey]?["text"] ?? "", curChats[chatKey]?["recId"] ?? ""))
                        }
                        DispatchQueue.main.async {
                            completion?(chats, nil)
                        }
        }) { (error) in
                completion?(nil, error)
        }

    }
    
    
    
    
    
}
