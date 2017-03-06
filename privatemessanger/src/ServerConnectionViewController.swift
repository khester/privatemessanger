






let mySpecialNotificationKey = "com.khester.specialNotificationKey"
let checkUserNotificationKey = "com.checkuserkhester.specialNotificationKey"
let createConversationNotificationKey = "com.createConversationkhester.specialNotificationKey"
let registrationNotificationKey = "com.createRegistrationkhester.specialNotificationKey"
let loginNotificationKey = "com.loginkhester.specialNotificationKey"

import UIKit
import JSQMessagesViewController
import RealmSwift
import CryptoSwift



class ServerConnectionViewController: UIViewController, NSStreamDelegate, UITextViewDelegate
{
    
    
    //change the server Address to actual address if deploying
    
    // arbitrary server port
    
    var input : NSInputStream?
    var output : NSOutputStream?
    var messages : NSMutableString = ""
    var receiveMessage : String = ""
    var serverHadError  = false
    //var username : NSString = NSUserDefaults.standardUserDefaults().stringForKey("userEmail")!
    var conversationIdFromSendMessageToServer = ""
    var checkUserResponse = ""
    var createConversationResponse = ""
    
    
    
    func connect(serverPort: UInt32, serverAddress: CFString) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveMessageFromChatNotification:", name: sendMessageToServerNotificationKey, object: nil)
        
        print(serverPort)
        print(serverAddress)
        var readStream:  Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        //connect to the host
        CFStreamCreatePairWithSocketToHost(nil, serverAddress, serverPort, &readStream, &writeStream)
        
        self.input = readStream!.takeRetainedValue()
        self.output = writeStream!.takeRetainedValue()
        
        self.input!.delegate = self
        self.output!.delegate = self
        
        
        self.input!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        self.output!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        //open the connections!
        self.input!.open()
        self.output!.open()
        
        //send confirmation to server that you've logged on.
        let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
        
        if(isUserLoggedIn) {
            let loginString : NSMutableString = "usr>"
            print("_______________HEEEEREEEE________")
            let jsonMessageDict = ["type":"login", "phone":NSUserDefaults.standardUserDefaults().stringForKey("userPhone")!, "password":NSUserDefaults.standardUserDefaults().stringForKey("userPassword")!]
            if NSJSONSerialization.isValidJSONObject(jsonMessageDict) { // True
                do {
                    //dict to json
                    let rawData = try NSJSONSerialization.dataWithJSONObject(jsonMessageDict, options: .PrettyPrinted)
                    let str = NSString(data: rawData, encoding: NSUTF8StringEncoding)
                    loginString.appendString(str as! String)
                    let rawString = loginString.dataUsingEncoding(NSASCIIStringEncoding)
                    serverConnector.output!.write(UnsafePointer<UInt8>(rawString!.bytes), maxLength: loginString.length)
                } catch {
                    // Handle Error
                }
            }
        }
    }
    
    //asynchronous event processing
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch(eventCode) {
        case NSStreamEvent.OpenCompleted:
            break
            
        //Information is available to pick up from server
        case NSStreamEvent.HasBytesAvailable:
            if aStream == self.input {
                while self.input!.hasBytesAvailable {
                    let bufferSize = 1024
                    var buffer = Array<UInt8>(count: bufferSize, repeatedValue: 0)
                    let bytesRead = self.input!.read(&buffer, maxLength: bufferSize)
                    if bytesRead >= 0 {
                        let output = NSString(bytes: &buffer, length: bytesRead, encoding: NSUTF8StringEncoding)
                        messages = ""
                        self.messages.appendString(output! as String)
                        self.receiveMessage = self.messages as String
                        print(receiveMessage, "receive message")
                        print("HERRRRREEEEEEEEEEEERRRRRRRRRRREEEEEE")

                        var typeofmsg = ""
                        
                        
                        let data: NSData = receiveMessage.dataUsingEncoding(NSUTF8StringEncoding)!
                        let ss = String(data: data, encoding: NSUTF8StringEncoding)
                        print("ss", ss)
                        if((ss?.isEmpty) == nil){
                            print("ss is empty")
                            
                        } else {
                            let object = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                            if let dictionary = object as? [String: AnyObject] {
                                guard let type = dictionary["type"] as? String else { print("hello world")
                                    return }
                                typeofmsg = type
                            }
                            if typeofmsg == "newmessage" {
                                print(object)
                                receiveMessageFromServer(object as! [String : AnyObject])
                                
                            } else if typeofmsg == "createconversation" {
                                print("here")
                                print(object)
                                createConversationResponse = receiveMessage
                                NSNotificationCenter.defaultCenter().postNotificationName(createConversationNotificationKey, object: self)
            
                            } else if typeofmsg == "checkuser" {
                                checkUserResponse = receiveMessage
                                print(receiveMessage)
                                newUserListener.checkUserNotification()

                            //NSNotificationCenter.defaultCenter().postNotificationName(checkUserNotificationKey, object: self)
                                
                            } else if typeofmsg == "registration" {
                                NSNotificationCenter.defaultCenter().postNotificationName(registrationNotificationKey, object: self)
                            }
                            else if typeofmsg == "login" {
                                let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
                                
                                if(!isUserLoggedIn) {
                                NSNotificationCenter.defaultCenter().postNotificationName(loginNotificationKey, object: self)
                                }
                            }
                            
                        }
                    }
                }
                break
            }
        case NSStreamEvent.HasSpaceAvailable:
            break
            
        case NSStreamEvent.ErrorOccurred:
            self.serverHadError = true
            break
            
        case NSStreamEvent.EndEncountered:
            self.serverHadError = true
            self.navigationController?.popViewControllerAnimated(true)
            
            break
            
        default:
            break
            
        }
        
    }
    override func viewDidAppear(animated: Bool) {
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        self.input!.close()
        self.output!.close()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificationSentLabel", name: mySpecialNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkUserNotification", name: checkUserNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "createConversationNotificationKey", name: checkUserNotificationKey, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "com.createRegistrationkhester.specialNotificationKey", name: registrationNotificationKey, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "com.loginkhester.specialNotificationKey", name: loginNotificationKey, object: nil)
        
    }
    
    func receiveMessageFromChatNotification(notification : NSNotification) {
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        conversationIdFromSendMessageToServer = userInfo["ConversationId"]!
        print(conversationIdFromSendMessageToServer)
        sendMessageToServer(conversationIdFromSendMessageToServer)
    }
    
    
    func sendMessageToServer(conversationId : String) {
        let senderConversation = try! Realm().objects(Conversation).filter("id == \(conversationId)").first
        let lastMessage = (senderConversation?.messageList.last)!
        
        //let key = "bbC2H19lkVbQDfakxcrtNMQdd0Flo321" // length == 32
        let key = senderConversation?.conversationKey
        let iv = "gqLOHUioQ0QjhuvI" // length == 16
        let enc = try! lastMessage.text.aesEncrypt(key!, iv: iv)
        print("enc:\(enc)")
        let jsonMessageDict = ["type":"newmessage", "conversationid":senderConversation!.id, "message":[["text":enc, "senderid":lastMessage.senderId, "senderDisplayName":lastMessage.senderDisplayName]]]
        
        if NSJSONSerialization.isValidJSONObject(jsonMessageDict) { // True
            do {
                //dict to json
                let rawData = try NSJSONSerialization.dataWithJSONObject(jsonMessageDict, options: .PrettyPrinted)
                let str = NSString(data: rawData, encoding: NSUTF8StringEncoding)
                let messageString : NSMutableString = "msg>"
                messageString.appendString(str! as String)
                let rawString = messageString.dataUsingEncoding(NSASCIIStringEncoding)!
                self.output!.write(UnsafePointer<UInt8>(rawString.bytes), maxLength: messageString.length)
            } catch {
                // Handle Error
            }
        }
        
    }
    
    func receiveMessageFromServer(object: [String: AnyObject]) {
        print("starting receive message")
        guard let conversationId = object["conversationid"] as? Int,
            let newmessage = object["message"] as? [[String: AnyObject]]
            else {return }
        let senderConversation = try! Realm().objects(Conversation).filter("id == \(conversationId)").first
        for message in newmessage {
            guard let text = message["text"] as? String,
                let senderId = message["senderid"] as? String,
                let senderDisplayName = message["senderDisplayName"] as? String
                else { print("json error")
                    break }
            let date = NSDate()
            
            //let key = "bbC2H19lkVbQDfakxcrtNMQdd0Flo321" // length == 32
            
            
            let key = senderConversation?.conversationKey
            let iv = "gqLOHUioQ0QjhuvI" // length == 16
            let s = text
            let dec = try? s.aesDecrypt(key!, iv: iv)
            //print("enc:\(enc)") // 2r0+KirTTegQfF4wI8rws0LuV8h82rHyyYz7xBpXIpM=
            print("dec:\(dec)") // string to encrypt
            var receivingMessage = MessageStructure(value: [text+"warning! this message was encrypted with wrong key", senderId, senderDisplayName, date])
            if(dec != nil){
                receivingMessage = MessageStructure(value: [dec!, senderId, senderDisplayName, date])

            }
            
            try! uiRealm.write({ () -> Void in
                senderConversation?.messageList.append(receivingMessage)
            })
            

        }
        NSNotificationCenter.defaultCenter().postNotificationName(mySpecialNotificationKey, object: self)
    }
    
    
    func converFromJsonToMessage() {
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



extension String {
    func aesEncrypt(key: String, iv: String) throws -> String{
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        let enc = try AES(key: key, iv: iv, blockMode:.CBC, padding: PKCS7()).encrypt(data!.arrayOfBytes())
        let encData = NSData(bytes: enc, length: Int(enc.count))
        let base64String: String = encData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0));
        let result = String(base64String)
        return result
    }
    
    func aesDecrypt(key: String, iv: String) throws -> String {
        let data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions(rawValue: 0))
        let dec = try AES(key: key, iv: iv, blockMode:.CBC).decrypt(data!.arrayOfBytes())
        let decData = NSData(bytes: dec, length: Int(dec.count))
        let result = NSString(data: decData, encoding: NSUTF8StringEncoding)
        return String(result!)
    }
}

