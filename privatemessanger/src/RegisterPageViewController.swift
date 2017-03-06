//
//  RegisterPageViewController.swift
//  fdsfa
//
//  Created by Roman on 03.04.16.
//  Copyright © 2016 Roman. All rights reserved.
//

import UIKit

class RegisterPageViewController: UIViewController {
    
    @IBOutlet weak var userPhoneTextField: UITextField!
    
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBAction func accoutOwnerTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func RegisterButtonTapped(sender: AnyObject) {
        let userName = userNameTextField
        let userPassword = userPasswordTextField
        let userRepeatPassword = repeatPasswordTextField
        let userPhone = userPhoneTextField
        // check for empy fields
        //save data
        //display alert message confirmation
        if (userName.text!.isEmpty || userPassword.text!.isEmpty ||
            userRepeatPassword.text!.isEmpty || userPhone.text!.isEmpty)   {
            displayAlertMessage("All fields are required")
            return
            //display an alert message
        }
        
        if(userPassword.text! != userRepeatPassword.text!) {
            //display an alert message
            displayAlertMessage("Passwords do not match")
            return
        }
        
        
        let loginString : NSMutableString = "reg>"
        
        
        let jsonMessageDict = ["type":"registration", "phone":userPhone.text!,
                               "name":userNameTextField.text!, "password":userPassword.text!]
        
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
    
    func displayAlertMessage(userMessage : String) {
        let myAlert = UIAlertController(title: "Alert", message: userMessage,preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:nil)
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "registrationNotification", name: registrationNotificationKey, object: nil)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func registrationNotification() {
        var registerMessage = serverConnector.receiveMessage
        var name = userNameTextField.text!
        var phone = ""
        var id = 0
        let data: NSData = registerMessage.dataUsingEncoding(NSUTF8StringEncoding)!
        let object = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        if let dictionary = object as? [String: AnyObject] {
            let myresult = readJSONObject(dictionary)
            name = myresult.0
            id = myresult.1
        }
        
        let newProfile = Profile(value: [name,phone,id])
        
         try! uiRealm.write({ () -> Void in
         uiRealm.add(newProfile)
         })
        NSUserDefaults.standardUserDefaults().setObject(userPhoneTextField.text!, forKey: "userPhone")
        NSUserDefaults.standardUserDefaults().setObject(userPasswordTextField.text!, forKey: "userPassword")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let myAlert = UIAlertController(title: "Great!", message: "Registration is successful. Thank you!", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func readJSONObject(object: [String: AnyObject]) -> (String, Int) {
        guard let phone = object["phone"] as? String,
            let id = object["id"] as? Int
            else { print("hello world")
                return("hello world",12) }
        return(phone,id)
    }

    
}
