//
//  QRCodeViewController.swift
//  QRCode
//
//  Created by Alan Cota on 2/10/17.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

import UIKit
import MASFoundation
import MASUI
import SVProgressHUD

class QRCodeViewController: UIViewController {

    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var userStatus: UIImageView!
    @IBOutlet weak var refreshLogin: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //Notification to take care of the session being shared
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(self.masProximityLogin(_:)),
            name:NSNotification.Name("MASDeviceDidReceiveAuthorizationCodeFromProximityLoginNotification"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(self.userAuthenticated(_:)),
            name:NSNotification.Name("MASUserDidAuthenticateNotification"),
            object: nil)
        
        
        //Starting MAS SDK
        
        //Start activity view
        SVProgressHUD.show(withStatus: "Starting MAS")
        
        MAS.setGrantFlow(MASGrantFlow.password)
        MAS.start(withDefaultConfiguration:true, completion:{ (completed: Bool, error: Error?) in
            
            //Stop activity view
            SVProgressHUD.dismiss()
            
            //Print a message whether the SDK was initialized or not
            let sdkResult = String(format: "MAS start result: <<<[ %@ ]>>>", completed ? "Yes" : "No")
            debugPrint(sdkResult)
            
            //Check the error
            if(error != nil) {
                //Printing the error
                debugPrint("MAS.start error: %@", error!.localizedDescription)
            }
            
        })
        
        //Call the dummy API to trigger the default login screen
        //self.loginUser()
    }

    // MARK: - Navigation
    
    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    //Handle the Notification when the session was shared
    func masProximityLogin(_ notification: Notification) {
        
        print(notification.debugDescription)
        //Present an Alert showing the results
        let alertController = UIAlertController(title: "MAS Proximity Login", message: "The session was shared successfully!", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
        self.userStatus.image = #imageLiteral(resourceName: "userfilled")
        
    }
    
    //Function to handle the user authentication Notification and change of status
    func userAuthenticated(_ notification: Notification) {
        
        if (MASUser.current().isAuthenticated) {
            self.userStatus.image = #imageLiteral(resourceName: "userfilled")
            print("User logout successfully")
            //Present an Alert showing the results
            let alertController = UIAlertController(title: "User Authenticated", message: "Welcome \(MASUser.current()!.userName)", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        
        
        if (MASUser.current() != nil) {
           
            if (MASUser.current()!.isAuthenticated) {
                
                MASUser.current().logout(completion: { (completed: Bool, error: Error?) in
                    
                    if (error != nil) {
                        
                        print("Error trying to logout the user")
                        //Present an Alert showing the results
                        let alertController = UIAlertController(title: "Error", message: "The user coudl not be logged out", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                    
                    self.userStatus.image = #imageLiteral(resourceName: "usernotfilled")
                    
                    print("User logout successfully")
                    //Present an Alert showing the results
                    let alertController = UIAlertController(title: "User Logout", message: "The user has been logged out!", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                })
            }
            
        } else {
            
            //Present an Alert showing the results
            let alertController = UIAlertController(title: "User Logout", message: "You need to login first, before logout", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        
        
        
    }
    
    //Function to call an API and trigger the default MAG login screen
    func loginUser() {
        
        //Make an API Call to wake up the default login screen
        MAS.getFrom("/protected/resource/products", withParameters: ["operation":"listProducts"], andHeaders: nil, completion: {response, error in
            
            
            
        })
        
    }
    
    //Force the login screen to come up
    @IBAction func refreshTapped(_ sender: Any) {
        
        loginUser()
        
    }
    
    
    
}
