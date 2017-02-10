//
//  ShareVC.swift
//  PhotoShare
//
//  Created by Bill Banks on 2/3/17.
//  Copyright © 2017 Ourweb.net. All rights reserved.
//

import UIKit
import WebKit
import MediaPlayer
import MobileCoreServices
import AWSMobileHubHelper
import AWSDynamoDB
import BSImagePicker
import Photos

import ObjectiveC

class ShareVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var list = [Friends]()
    
    @IBOutlet weak var friendtxt: UITextField!
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        

        // Do any additional setup after loading the view.
    }
  
    override func viewDidAppear(animated: Bool) {
         getdata()
    }
    
    private func showSimpleAlertWithTitle(title: String, message: String, cancelButtonTitle cancelTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    func sortdata() {
        
        for var x = 0;  x < list.count - 1; x++ {
            for var y = x + 1; y < list.count; y++ {
                if list[x]._friend  < list[y]._friend {
                   let temp = list[x]
                    list[x] = list[y]
                    list[y] = temp
                }
            }
        }
    }

    func getdata() {
         
        
        getshares()
      
    }
    
    
    func getshares() {
      //  var list = [Friends]()
        list.removeAll()
        
        let fech = FriendsPrimaryIndex(userna: AWSIdentityManager.defaultIdentityManager().userName!)
        
        
        
        fech.queryWithPartitionKeyWithCompletionHandler({ ( reponse: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            
            if error == nil {
                
                for item in reponse!.items  {
                    let rec = item as! Friends
                    self.list.append(rec)
                    
                    
                }
                self.sortdata()
                
                self.tableview.reloadData()
            }
            
            
        })
        
        
//        return list
        
    }
    
    
    @IBAction func add_click(sender: AnyObject) {
        if let username = friendtxt.text {
            
            let usermaster: String = UserMasterTable().checkuser(username)
            
       //     if usermaster != "" {
                let dbb = FriendsTable()
                dbb.addfriend(username)
                getdata()
                
         //   } else {
             // self.showSimpleAlertWithTitle("Not Found", message: "Friend not found", cancelButtonTitle: "OK")
           // }
            
            
            
        }
        friendtxt.text = ""
    }
 
    @IBAction func delete_click(sender: AnyObject) {
        if let un = friendtxt.text {
            let dbb = FriendsTable()
            dbb.deletefriend(un)
            getdata()
            
        }
    }
    
    
    //table view
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("friendcell", forIndexPath: indexPath)
            cell.textLabel?.text = list[indexPath.row]._friend
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        friendtxt.text = list[indexPath.row]._friend
    }

}
