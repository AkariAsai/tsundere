//
//  LoginViewController.swift
//  tsundoku
//
//  Created by Hiroaki KARASAWA on 2017/02/04.
//  Copyright © 2017年 浅井紀子. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import FBSDKCoreKit
import FBSDKLoginKit


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    let loginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if FBSDKAccessToken.current() != nil {
            self.transitToGraphView()
        } else {
            initLoginButton()
        }
    }
    
    func initLoginButton() {
        loginButton.center = self.view.center
        loginButton.delegate = self
        loginButton.readPermissions = [ "public_profile", "email", "user_friends" ]
        
        self.view.addSubview(loginButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if ((error) != nil) {
            self.showSimpleMessageDialog(title: "Authentication Error", message: "Some errors occured while executing authentication process.")
        } else if result.isCancelled {
            self.showSimpleMessageDialog(title: "Authentication Error", message: "Authentication denied.")
        } else if !([ "public_profile", "email", "user_friends" ] as Set).isSubset(of: result.grantedPermissions) {
            self.showSimpleMessageDialog(title: "Authentication Error", message: "Some permissions are not granted.")
        } else {
            print("Facebook Login is succeded")
            
            self.fetchUserData() { id, name in
                self.registerUserInfo(id, name: name)
                
                self.fetchFriendsData() { friends in
                    pushUserData(id: id, name: name, friends: friends) {
                        self.transitToGraphView()
                    }
                }
            }
        }
    }
    
    func registerUserInfo(_ id : String, name : String) {
        let ud = UserDefaults.standard
        
        ud.set(id, forKey: "id")
        ud.set(name, forKey: "name")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func showSimpleMessageDialog(title : String, message : String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchUserData(callback : @escaping (String, String) -> Void) {
        let parameters = [ "fields": "id,name" ]
        
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: { (connection, result, error) -> Void in
            if error != nil {
                print("Error: \(error)")
            } else {
                let object = JSON(result!)
                let name = object["name"].string!, id = object["id"].string!
                
                callback(id, name)
            }
        })
    }
    
    func fetchFriendsData(callback: @escaping ([ [ String : String ] ]) -> Void) {
        FBSDKGraphRequest(graphPath: "me/friends", parameters: [ "fields": "id,name" ]).start(completionHandler: { (connection, result, error) -> Void in
            if error != nil {
                print("Error: \(error)")
                return
            }
            
            var friends : [ [String : String] ] = []
                
            for friend in JSON(result!)["data"] {
                friends.append([ "id" : friend.1["id"].string!, "name" : friend.1["name"].string! ])
            }
            
            callback(friends)
        })
    }
    
    func transitToGraphView() {
        self.present(ViewController(), animated: true, completion: nil)
    }
}

