//
//  ConversationCell.swift
//  fdsfa
//
//  Created by Roman on 04.03.16.
//  Copyright © 2016 Roman. All rights reserved.
//

import UIKit
import RealmSwift


class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var lastMessageTextField: UILabel!
    var conversation: Conversation! {
        didSet {
            firstNameLabel.text = conversation.name
            if (conversation.messageList.last?.text.isEmpty != nil) {
                lastMessageTextField.text = conversation.messageList.last?.text
            }
            userImageView.image = imageForUser(0)
        }
    }
    
    func imageForUser(id:Int) -> UIImage? {
        let imageName = "\(id)mainimage"
        return UIImage(named: imageName)
    }
    
}
