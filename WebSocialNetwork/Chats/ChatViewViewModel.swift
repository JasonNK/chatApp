//
//  ChatViewViewModel.swift
//  WebSocialNetwork
//
//  Created by Jason on 2/5/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import Foundation
import Firebase

class ChatViewViewModel {
    var chats = [(String, String)]()
    func fetchAllChats(messageId: String, completion: (([(String, String)]?, Error?)->Void)?) {
        FirebaseUtil.shared.fetchAllChats(messageId: messageId) { (arrTupleOp, errorOp) in
            self.chats = arrTupleOp ?? []
            completion?(self.chats, errorOp)
        }

    }
    
    func getChatsCount() -> Int {
        self.chats.count
    }
    
    func getChatObject(index: Int) throws -> (String, String)? {
        if index >= self.chats.count {
            throw AppErrors.indexOutOfBound
            
        }
        else {
            return self.chats[index]
            
        }
    }
}
