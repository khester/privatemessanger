//
//  MessageStructure.swift
//  fdsfa
//
//  Created by Roman on 18.04.16.
//  Copyright © 2016 Roman. All rights reserved.
//

import Foundation
import RealmSwift
import JSQMessagesViewController

class MessageStructure: Object {
    
    dynamic var text = ""
    dynamic var senderId = ""
    dynamic var senderDisplayName  = ""
    dynamic var date = NSDate()

}
