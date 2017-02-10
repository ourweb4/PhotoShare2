//
//  friendgalleryVC.swift
//  PhotoShare
//
//  Created by Bill Banks on 2/6/17.
//  Copyright © 2017 Ourweb.net. All rights reserved.
//

import UIKit
import WebKit
import MediaPlayer
import MobileCoreServices
import AWSMobileHubHelper
import BSImagePicker
import Photos


class friendgalleryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    internal var vfriend = Friends()
    
    var prefix: String!
    @IBOutlet weak var tableview: UITableView!
    
    private var manager: AWSUserFileManager!
    private var contents: [AWSContent] = [AWSContent]()
    private var marker: String?
    
    private var images: [UIImage] = [UIImage]()

    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.manager = AWSUserFileManager.defaultUserFileManager()
        self.manager.clearCache()
        let userId = vfriend._userId!
        label.text = "Photo Gallery of \(vfriend._username!)"
        self.prefix = "public/\(userId)/"
        print(self.prefix)
        reloadobjects()
        
    }
    
    private func showSimpleAlertWithTitle(title: String, message: String, cancelButtonTitle cancelTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    
    // download section
    
    
    
    private func downloadContent(content: AWSContent, pinOnCompletion: Bool) {
        content.downloadWithDownloadType(.IfNewerExists, pinOnCompletion: pinOnCompletion, progressBlock: {[weak self](content: AWSContent?, progress: NSProgress?) -> Void in
            guard let strongSelf = self else { return }
            if strongSelf.contents.contains( {$0 == content} ) {
                let row = strongSelf.contents.indexOf({$0  == content!})!
                let indexPath = NSIndexPath(forRow: row, inSection: 1)
                //     strongSelf.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
            }, completionHandler: {[weak self](content: AWSContent?, data: NSData?, error: NSError?) -> Void in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("Failed to download a content from a server. \(error)")
                    strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to download a content from a server.", cancelButtonTitle: "OK")
                }
                //   strongSelf.updateUserInterface()
            })
    }
    
    private func downloadObjects() {
        //get all objects/files
        //self.diskspace = 0
        
        manager.listAvailableContentsWithPrefix(prefix, marker: marker, completionHandler: {[weak self](result: [AWSContent]?, rmark: String?, error: NSError?) -> Void in
            guard let strongSelf = self else { return }
            if  error != nil {
                print (error)
            }
            if let resultArray: [AWSContent] = result  {
                for content: AWSContent in resultArray {
                    if !content.cached && !content.directory {
                        //print("**Key=\(content.key)")
                        self!.downloadContent(content, pinOnCompletion: true)
                        self!.contents.append(content)
         //               self!.diskspace =  self!.diskspace + content.knownRemoteByteCount
                        
                       
                    }
                }
                 self!.tableview.reloadData()
       //         self?.checkspace()
            }
            })
    }
    
    private func reloadobjects() {
        contents.removeAll()
        
            downloadObjects()
        
        //        self.tableview.reloadData()
    }
    
    //segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ident = segue.identifier {
            switch ident {
            case "showfriendimage" :
                let showimagesvc = segue.destinationViewController as! FriendImageVC
   //             showimagesvc.vfriend = currfriend
                showimagesvc.conrents = self.contents
                showimagesvc.index = sender as! Int
                

                
            default:
                break
            }
        }
    }
    

    
    
    //table view section
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("fphotocell") as?  FPhotoCell {
            let content = contents[indexPath.row]
            cell.confcell(content, prefix: prefix)
            return cell
        } else
        {
            let cell = FPhotoCell()
            
            let content = contents[indexPath.row]
            
            cell.confcell(content, prefix: prefix)
            // cell.titlelab.text = content.key
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
            performSegueWithIdentifier("showfriendimage", sender: indexPath.row)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("showfriendimage", sender: indexPath.row)
        
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contents.count
        
    }

}
