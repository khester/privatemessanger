//
//  LoginViewController.swift
//  fdsfa
//
//  Created by Roman on 03.04.16.
//  Copyright © 2016 Roman. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        let userPhone = userEmailTextField.text!
        let userPassword = userPasswordTextField.text!
        let userPhoneStored = NSUserDefaults.standardUserDefaults().stringForKey("userPhone")
        let userPasswordStored = NSUserDefaults.standardUserDefaults().stringForKey("userPassword");
        
        let loginString : NSMutableString = "usr>"
        
        let jsonMessageDict = ["type":"login", "phone":userPhone, "password":userPassword]
        
        let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
        if(isUserLoggedIn) {
            if(userPhoneStored == userPhone) {
                if(userPasswordStored == userPassword) {
                    //login is successfull
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    displayAlertMessage("Wrong password. Try it again!")
                }
            }
            else {
                displayAlertMessage("Wrong phone. Try it again!")
            }
        } else {
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
    
    func loginNotification() {
        let loginMessage = serverConnector.receiveMessage
        print(loginMessage)
        var name = ""
        var phone = ""
        var pass = ""
        var id = 0
        var error = ""
        let data: NSData = loginMessage.dataUsingEncoding(NSUTF8StringEncoding)!
        let object = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        if let dictionary = object as? [String: AnyObject] {
            let myresult = readJSONObject(dictionary)
            phone = myresult.0
            id = myresult.1
            pass = myresult.2
            error = myresult.3
            name = myresult.4
        }
        if(error=="true") {
            print("takie dela")
        } else {
            //login is successfull
            let newProfile = Profile(value: [name,phone,id])
            
            try! uiRealm.write({ () -> Void in
                uiRealm.add(newProfile)
            })
            NSUserDefaults.standardUserDefaults().setObject(phone, forKey: "userPhone")
            NSUserDefaults.standardUserDefaults().setObject(pass, forKey: "userPassword")            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    func readJSONObject(object: [String: AnyObject]) -> (String, Int, String, String, String) {
        guard let phone = object["phone"] as? String,
            let id = object["id"] as? Int,
            let password = object["password"] as? String,
            let name = object["name"] as? String,
        let error = object["error"] as? String
            else { print("hello world")
                return("hello world",12,"sda","dsa","dsa") }
        return(phone,id,password,error,name)
    }

    
    func displayAlertMessage(userMessage : String) {
        let myAlert = UIAlertController(title: "Unable to log in", message: userMessage,preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil)
        
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginNotification", name: loginNotificationKey, object: nil)
        // Do any additional setup after loading the view.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
