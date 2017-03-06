//
//  ConversationListViewController.swift
//  fdsfa
//
//  Created by Roman on 04.03.16.
//  Copyright © 2016 Roman. All rights reserved.
//

import UIKit
import RealmSwift

class ConversationListViewController: UITableViewController {
    
    @IBOutlet var conversationListTableView: UITableView!
    
    var conversationList : Results<Conversation>!
    
    override func viewWillAppear(animated: Bool) {
        updateConversationView()
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = false
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    
    func updateConversationView(){
        
        conversationList = uiRealm.objects(Conversation)
        self.conversationListTableView.setEditing(false, animated: true)
        self.conversationListTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //кол-во элементов для каждой из секций
        
        if let conversationCount = conversationList{
            return conversationCount.count
        }
        return 0
        
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("ConversationCell", forIndexPath: indexPath)
                as! ConversationCell
            let list = conversationList[indexPath.row] as Conversation
            cell.conversation = list
            return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //а это вызывается если юзер кликнул по какой-то ячейке
        self.performSegueWithIdentifier("openChatSegue", sender: self.conversationList[indexPath.row])
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //а здесь нао вернуть кол-во секций(для простой таблицы это 1)
        return 1
    }
    
    @IBAction func cancelToFindFriendViewController(segue:UIStoryboardSegue) {
        
    }
    @IBAction func cancelToCreateChatViewController(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func saveFriendDetail(segue:UIStoryboardSegue) {
    }
    
    override func viewDidAppear(animated: Bool) {
        let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
        if(!isUserLoggedIn) {
            self.performSegueWithIdentifier("loginView", sender: self)

        }
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.performSegueWithIdentifier("loginView", sender: self)
        try! uiRealm.write({ () -> Void in
            uiRealm.deleteAll()
        })
        
       
    }
    
    //send user data from cell to chatViewcontroller 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "openChatSegue" {
            let sendUserDataToChat = segue.destinationViewController as! ChatViewController
            sendUserDataToChat.currentConversation = sender as! Conversation
        }
    }
}








