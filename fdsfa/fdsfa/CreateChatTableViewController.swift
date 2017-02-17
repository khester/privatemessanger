//
//  CreateChatTableViewController.swift
//  fdsfa
//
//  Created by Roman on 29.04.16.
//  Copyright © 2016 Roman. All rights reserved.
//

import UIKit
import RealmSwift


class CreateChatTableViewController: UITableViewController {
    var ContactList : Results<Conversation>!
    var dictAddContacts = [Int: User2]()
    var jsonResponseFromServer = ""
    @IBAction func createChat(sender: AnyObject) {
        sendRequestToServer()
    }
    
    @IBOutlet weak var conversationName: UITextField!
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "createConversationNotification", name: createConversationNotificationKey, object: nil)
        super.viewDidLoad()
    }
    
    
    func createConversationNotification() {
        jsonResponseFromServer = serverConnector.createConversationResponse
        let newConversation = Conversation()
        print("jsonResponseFromServer",jsonResponseFromServer)
        let data: NSData = jsonResponseFromServer.dataUsingEncoding(NSUTF8StringEncoding)!
        let object = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        if let dictionary = object as? [String: AnyObject] {
            let myresult = readJSONObject(dictionary)
            newConversation.name = myresult.0
            newConversation.id = myresult.1
            newConversation.userList.appendContentsOf(myresult.2)
        }
        //add to data base
        print(newConversation.name)
        try! uiRealm.write({ () -> Void in
            uiRealm.add(newConversation)
        })
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        updateContactView()
    }
    func updateContactView(){
        ContactList = uiRealm.objects(Conversation).filter("userList.@count == \(2)")
        //self.ContactListTableView.setEditing(false, animated: true)
        //self.ContactListTableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //кол-во элементов для каждой из секций
        
        if let conversationCount = ContactList{
            return conversationCount.count
        }
        return 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("CreateChatTableViewCell", forIndexPath: indexPath)
                as! CreateChatTableViewCell
            let list = ContactList[indexPath.row] as Conversation
            cell.conversation = list
            return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let dictcell = tableView.cellForRowAtIndexPath(indexPath) as! CreateChatTableViewCell
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if  cell!.accessoryType == .None {
            dictAddContacts[(dictcell.conversation.userList.first?.id)!] = dictcell.conversation.userList.first
            cell?.accessoryType = .Checkmark
        } else {
            dictAddContacts.removeValueForKey((dictcell.conversation.userList.first?.id)!)
            cell?.accessoryType = .None

        }
    }
    
    func sendRequestToServer() {
        var newConversationDict = [String:AnyObject]()
        var userlist = [AnyObject]()
        var userdict = [String:AnyObject]()
        for user2 in dictAddContacts.values {
            userdict["name"] = user2.name
            userdict["id"] = user2.id
            userdict["phone"] = user2.phone
            userlist.append(userdict)
        }
        newConversationDict["type"] = "createconversation"
        newConversationDict["users"] = userlist
        newConversationDict["conversationname"] = conversationName.text!
        if NSJSONSerialization.isValidJSONObject(newConversationDict) { // True
            do {
                //dict to json
                let rawData = try NSJSONSerialization.dataWithJSONObject(newConversationDict, options: .PrettyPrinted)
                let str = NSString(data: rawData, encoding: NSUTF8StringEncoding)
                jsonResponseFromServer = str as! String
                let messageString : NSMutableString = "msg>"
                messageString.appendString(str! as String)
                let rawString = messageString.dataUsingEncoding(NSASCIIStringEncoding)!
                serverConnector.output!.write(UnsafePointer<UInt8>(rawString.bytes), maxLength: messageString.length)
            } catch {
                // Handle Error
            }
        }

    }
    
    func readJSONObject(object: [String: AnyObject]) -> (String, Int, [User2]) {
     
        var newUserList = [User2]()
        guard let newConversationId = object["conversationid"] as? Int,
            let newConversationName = object["conversationname"] as? String,
            let userss = object["users"] as? [[String: AnyObject]]  else { print("hello worl21312d")
                return ("error",0,newUserList) }
        for user in userss {
            guard let name = user["name"] as? String,
                let phone = user["phone"] as? String,
                let id = user["id"] as? Int else { break }
            let newUser = User2()
            newUser.name = name
            newUser.phone = phone
            newUser.id = id
            newUserList.append(newUser)
        }
        return(newConversationName, newConversationId, newUserList)
      
    }
    

    

}
