//
//  FriendsVC.swift
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

class FriendsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    var list = [Friends]()
    var currfriend = Friends()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self

        // Do any additional setup after loading the view.
    }
 
    override func viewDidAppear(animated: Bool) {
        getdata()
    }
    func sortdata() {
        
        for var x = 0;  x < list.count - 1; x++ {
            for var y = x + 1; y < list.count; y++ {
                if list[x]._username < list[y]._username {
                    let temp = list[x]
                    list[x] = list[y]
                    list[y] = temp
                }
            }
        }
    }
    
    func getdata() {
        // let db = FriendsTable()
        
        getfriends()
        }
    
    
    func getfriends() {
        //var list = [Friends]()
        list.removeAll()
        
        let fech = FriendsFriendUsername(fri: AWSIdentityManager.defaultIdentityManager().userName!)
        
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
        
        
    }

    //segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ident = segue.identifier {
            switch ident {
            case "showgallery" :
                let showimagesvc = segue.destinationViewController as! friendgalleryVC
                    showimagesvc.vfriend = currfriend
                
                
            default:
                break
            }
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
        cell.textLabel?.text = list[indexPath.row]._username
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currfriend = list[indexPath.row]
         performSegueWithIdentifier("showgallery", sender: indexPath)
    }

    
}
