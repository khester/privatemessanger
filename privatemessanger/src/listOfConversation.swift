//
//  listOfConversation.swift
//  fdsfa
//
//  Created by Roman on 18.04.16.
//  Copyright © 2016 Roman. All rights reserved.
//

import Foundation
import RealmSwift

class listOfConversation: Object {
    let conversationList = List<Conversation>()
}
