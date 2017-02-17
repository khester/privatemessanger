//
//  ContactTableViewCell.swift
//  fdsfa
//
//  Created by Roman on 29.04.16.
//  Copyright © 2016 Roman. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var userFirstName: UILabel!
    @IBOutlet weak var userLastName: UILabel!
    
    var conversation: Conversation! {
        didSet {
            userFirstName.text! = conversation.name
            userLastName.text! = ""
        }
    }

}
