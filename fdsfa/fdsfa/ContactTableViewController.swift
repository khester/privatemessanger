//
//  ContactTableViewController.swift
//  fdsfa
//
//  Created by Roman on 26.04.16.
//  Copyright © 2016 Roman. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyRSA

class ContactTableViewController: UITableViewController {

    var ContactList : Results<Conversation>!
    
    @IBOutlet var ContactListTableView: UITableView!
    
    override func viewDidLoad() {
        

        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool) {
        updateContactView()
    }
    func updateContactView(){
        ContactList = uiRealm.objects(Conversation).filter("userList.@count == \(2)")
        self.ContactListTableView.setEditing(false, animated: true)
        self.ContactListTableView.reloadData()
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
            
            
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactTableViewCell", forIndexPath: indexPath)
                as! ContactTableViewCell
            let list = ContactList[indexPath.row] as Conversation
            cell.conversation = list
            return cell
    }
    
    @IBAction func cancelToNewContactViewController(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func saveContactDetail(segue:UIStoryboardSegue) {
        /*
        if let playerDetailsViewController = segue.sourceViewController as? PlayerDetailsViewController {
        
        //add the new player to the players array
        if let player = playerDetailsViewController.player {
        players.append(player)
        
        //update the tableView
        let indexPath = NSIndexPath(forRow: players.count-1, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        }
        
        */
    }


}
