//
//  FindFriendViewControllerTableViewController.swift
//  fdsfa
//
//  Created by Roman on 04.03.16.
//  Copyright © 2016 Roman. All rights reserved.
//

import UIKit
import RealmSwift

class FindFriendViewControllerTableViewController: UITableViewController {
    
    @IBAction func addNewContactButton(sender: AnyObject) {
        isContactRegisteredRequestToServer(userPhoneNumber.text!)
    }
    @IBOutlet weak var userPhoneNumber: UITextField!
    
    @IBOutlet weak var conversationKey: UITextField!

    
    var checkUserServerResponse = ""
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkUserNotification", name: checkUserNotificationKey, object: nil)
        super.viewDidLoad()
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func readJSONObject(object: [String: AnyObject]) -> (String, String, Int, String, Int) {
        guard let registered = object["registered"] as? String,
            let phone = object["phone"] as? String,
            let userId = object["userid"] as? Int,
            let conversationName = object["conversationname"] as? String,
            let conversationId = object["conversationid"] as? Int
            else {                 print("hello world")
                return("hello world","H",12,"hello world",13) }
        return(registered, phone, userId, conversationName, conversationId)
    }
    
    
    func checkUserNotification() {
        
        checkUserServerResponse = serverConnector.checkUserResponse
        print("CHEEEEEEEEEEECK")
        var conversationName = ""
        var userRegistered = ""
        var userPhone = ""
        var userId = 0
        var conversationId=0
        
        let data: NSData = checkUserServerResponse.dataUsingEncoding(NSUTF8StringEncoding)!
        let object = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        if let dictionary = object as? [String: AnyObject] {
            let myresult = readJSONObject(dictionary)
            userRegistered = myresult.0
            userPhone = myresult.1
            userId = myresult.2
            conversationName = myresult.3
            conversationId = myresult.4
        }
        
        
        print(userRegistered,userPhone , userId, conversationName , conversationId)
        
        
        if userRegistered == "true" {
            addContactToServer(userPhone, userdId: userId, conversationName:conversationName , conversationId: conversationId)
        } else {
            let myAlert = UIAlertController(title: "Not Registered", message: "This contact is not registered in chat yet. Sorry!", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {action in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            myAlert.addAction(okAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
            
        }
    }
    
    func isContactRegisteredRequestToServer(userId : String) {
        
        
        let messageString : NSMutableString = "msg>"
        
        let jsonMessageDict = ["type":"checkuser", "firstuserphone":myProfile.phone,"seconduserphone":userPhoneNumber.text!]
        
        if NSJSONSerialization.isValidJSONObject(jsonMessageDict) { // True
            do {
                //dict to json
                let rawData = try NSJSONSerialization.dataWithJSONObject(jsonMessageDict, options: .PrettyPrinted)
                let str = NSString(data: rawData, encoding: NSUTF8StringEncoding)
                messageString.appendString(str as! String)
                let rawString = messageString.dataUsingEncoding(NSASCIIStringEncoding)
                serverConnector.output!.write(UnsafePointer<UInt8>(rawString!.bytes), maxLength: messageString.length)
            } catch {
                // Handle Error
            }
        }
        
    }
    

    
    func displayAlertMessage(userMessage : String) {
        let myAlert = UIAlertController(title: "Error", message: userMessage,preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:nil)
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
        
    }
    
    func addContactToServer(phoneNumber : String, userdId: Int, conversationName : String, conversationId : Int) {
        //bbC2H19lkVbQDfakxcrtNMQdd0Flo321
        let newContact = User2()
        let newConversation = Conversation()
        newContact.name = conversationName
        newContact.id = userdId
        newContact.phone = phoneNumber        
        newConversation.name = conversationName
        newConversation.id = conversationId
        newConversation.userList.append(newContact)
        newConversation.userList.append(User2(value: [myProfile.name, myProfile.phone,myProfile.id]))
        addContactToDataBase(newConversation)
        //self.navigationController!.popViewControllerAnimated(true)
    
        
    }
    
    
    func addContactToDataBase(newConversation : Conversation) {
        try! uiRealm.write({ () -> Void in
            uiRealm.add(newConversation)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            
        }
    }
    
    
}
