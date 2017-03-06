//
//  CreateChatTableViewCell.swift
//  fdsfa
//
//  Created by Roman on 29.04.16.
//  Copyright © 2016 Roman. All rights reserved.
//

import UIKit

class CreateChatTableViewCell: UITableViewCell {


    @IBOutlet weak var contactName: UILabel!
    
    var conversation: Conversation! {
        didSet {
            contactName.text! = conversation.name
        }
    }
}
