//
//  Conversation.swift
//  fdsfa
//
//  Created by Roman on 18.04.16.
//  Copyright © 2016 Roman. All rights reserved.
//

import Foundation
import RealmSwift
import JSQMessagesViewController

class Conversation: Object {
    dynamic var name = ""
    dynamic var id = 0
    dynamic var dateOfLastMessage = NSDate()
    let userList = List<User2>()
    let messageList = List<MessageStructure>()
    dynamic var conversationKey = ""
    
}
