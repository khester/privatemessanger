

import UIKit
import JSQMessagesViewController
import RealmSwift
import SwiftyRSA

let sendMessageToServerNotificationKey = "com.sendMessageToServer.specialNotificationKey"


class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate,UITableViewDelegate, UINavigationControllerDelegate {
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    var messages = [JSQMessage]()
    
    var currentConversation : Conversation!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }

    
    /////////////////CHHAAANNNNNNNNNGGGGGEEEEEEEEEE ID and other
    
    func setup() {
        self.senderId = String(myProfile.id)
        self.senderDisplayName = myProfile.name
    }
    
    /////////////////////////////////
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        //currentConversation.messageList
        super.viewDidLoad()
        self.messages = loadConversationMessages(self.currentConversation.messageList)
        print(currentConversation.name)
      //  initConnection()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendMessageNotificationSentLabel", name: sendMessageToServerNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "actOnSpecialNotification", name: mySpecialNotificationKey, object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tabBarController?.tabBar.hidden = true
        self.setup()
        if(serverConnector.serverHadError) {
            self.navigationController!.popViewControllerAnimated(true)
        }
        
        if currentConversation.conversationKey.isEmpty {
            //1. Create the alert controller.
            let alert = UIAlertController(title: "Secure key error", message: "Please enter secure key for chat message encrtyprion", preferredStyle: .Alert)
            
            //2. Add the text field. You can configure it however you need.
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.placeholder = "secure key"
            })
          
            //3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                let textField = alert.textFields![0] as UITextField
                print("Text field: \(textField.text)")
                let key = "bbC2H19lkVbQDfakxcrtNMQdd0Flo321"
                let lenofstr = 32 - (textField.text!).characters.count
                
                let asd = key.substringToIndex(key.startIndex.advancedBy(lenofstr))
                let resultkey = textField.text!+asd
                
                try! uiRealm.write({ () -> Void in
                    self.currentConversation.conversationKey = resultkey
                })
            }))
            
            // 4. Present the alert.
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
        
    }
    
    func actOnSpecialNotification() {
        
        //RECEIVE MESSAGE
        receiveMessageFromServer()
        print("I heard the notification!", serverConnector.receiveMessage)
    }
    
  
    @IBAction func cancelChatViewController(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    func convertFromJSQtoMessageStructure(jsqmessage : JSQMessage) -> MessageStructure {
        let messagestructure = MessageStructure(value: [jsqmessage.text, jsqmessage.senderId, jsqmessage.senderDisplayName, jsqmessage.date])
        return messagestructure
    }
    
    func convertFromMessageStructureToJSQ(messagestructure: MessageStructure) -> JSQMessage {
        let jsqmessage = JSQMessage(senderId: messagestructure.senderId, senderDisplayName:  messagestructure.senderDisplayName, date:  messagestructure.date, text:  messagestructure.text)
        return jsqmessage
    }
    
    func loadConversationMessages(messageList : List<MessageStructure>) -> [JSQMessage] {
        let indexLastElement = messageList.count
        var resultMessages = [JSQMessage]()
        if indexLastElement >= 30 {
            for i in 1...30 {
                resultMessages.append(convertFromMessageStructureToJSQ(messageList[indexLastElement-(31-i)]))
            }
        } else if indexLastElement > 0{
            for i in 0...indexLastElement-1 {
                resultMessages.append(convertFromMessageStructureToJSQ(messageList[i]))
            }
        }
        return resultMessages
    }
    
    func sendNewMessageToDataBase(message : JSQMessage) {
        let messageForBase = convertFromJSQtoMessageStructure(message)
        try! uiRealm.write({ () -> Void in
            self.currentConversation.messageList.append(messageForBase)
            //self.selectedList.tasks.append(newTask)
            //self.readTasksAndUpateUI()
        })
        NSNotificationCenter.defaultCenter().postNotificationName(sendMessageToServerNotificationKey, object: self, userInfo:["ConversationId":"\(self.currentConversation.id)"])

    }
    
    func sendMessageNotificationSentLabel() {
    }
    
    func receiveMessageFromServer() {
        let convers = try! Realm().objects(Conversation).filter("id == \(self.currentConversation.id)").first
        let newJSQMessage = convertFromMessageStructureToJSQ((convers?.messageList.last)!)
        self.messages.append(newJSQMessage)
        self.reloadMessagesView()
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        sendNewMessageToDataBase(message)
        self.finishSendingMessage()

    }
    
    //image sending
    //--------------------------------------------
    
    func showAlert(){
        let alert = UIAlertController(title: "photo from",message: nil, preferredStyle: .ActionSheet)
        let firstAction = UIAlertAction(title: "camera", style: UIAlertActionStyle.Default){
            action in
            self.precentPickerController(.Camera)
        }
        let secondAction = UIAlertAction(title: "photolibrary", style: UIAlertActionStyle.Default){
            action in
            self.precentPickerController(.PhotoLibrary)
        }
        let cancelAction = UIAlertAction(title: "cancel", style: .Default,handler : nil)
        
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func precentPickerController(sourceType:UIImagePickerControllerSourceType){
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = self
            self.presentViewController(picker, animated:true, completion:nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: NSDictionary!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        let photoItem = JSQPhotoMediaItem(image: image)
        let message = JSQMessage(senderId: "1", displayName: "man", media: photoItem)
        sendMessage(message)

    }
    
    func sendMessage(message : JSQMessage){
        self.messages.append(message)
        self.reloadMessagesView()
        
    }
    
    
    //--------------------------------------------
    
    
    override func didPressAccessoryButton(sender: UIButton!) {
        showAlert()
    }
    
    
    
 

    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
       // serverConnector.input!.close()
      //  serverConnector.output!.close()
        
    }
    
    
    
  
    
}





