//
//  ViewController.swift
//  PhotoShare
//
//  Created by Bill Banks on 12/21/16.
//  Copyright © 2016 Bill Banks. All rights reserved.
//

import UIKit
import WebKit
import MediaPlayer
import MobileCoreServices
import AWSMobileHubHelper
import BSImagePicker
import Photos

import ObjectiveC
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var prefix: String!
    @IBOutlet weak var messlab: UILabel!
    
    @IBOutlet weak var verlab: UILabel!
    private var manager: AWSUserFileManager!
    private var contents: [AWSContent] = [AWSContent]()
    private var marker: String?
    private var username: String = ""
    private var images: [UIImage] = [UIImage]()
    private var diskspace: UInt = 0
    
    let datalimit: UInt = 1073741824     // 1 GB
    

    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var uploadbutton: UIButton!
    
    @IBOutlet weak var ActInt: UIActivityIndicatorView!
    
    
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        tableview.delegate = self
        tableview.dataSource = self
    }

    @IBAction func refresh_click(sender: AnyObject) {
        self.reloadobjects()
    }
   
    override func viewDidAppear(animated: Bool) {
           let version: String = NSBundle .mainBundle() .objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        verlab.text = "Ver.  \(version)"
        messlab.text = ""
        if (AWSIdentityManager.defaultIdentityManager().loggedIn) {
            uploadbutton.enabled =  true
            shareButton.enabled = true
            refreshButton.enabled = true
            self.manager = AWSUserFileManager.defaultUserFileManager()
            self.manager.clearCache()
            let userId = AWSIdentityManager.defaultIdentityManager().identityId!
           self.prefix = "public/\(userId)/"
            reloadobjects()
            self.username =   AWSIdentityManager.defaultIdentityManager().userName!
            let usertable = UserMasterTable()
            usertable.adduser(userId, username: self.username)
            
      
        } else {
            // dont allow upload if not login
            uploadbutton.enabled = false
            shareButton.enabled = false
            refreshButton.enabled = false
        }
    }
     
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // upload section
    @IBAction func upload_click(sender: AnyObject) {
         ImagePicker()
    }
   
    
    // Image picker
    private func ImagePicker() {
/*        let imagepickercontroler: UIImagePickerController = UIImagePickerController()
    
         imagepickercontroler.allowsEditing = false
        imagepickercontroler.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagepickercontroler.delegate = self
        self.presentViewController(imagepickercontroler, animated: true, completion: nil)
        */
        let vc = BSImagePickerViewController()
        images.removeAll()
        
        bs_presentImagePickerController(vc, animated: true,
                select: { (asset: PHAsset) -> Void in
                  // User selected an asset.
                 // Do something with it, start upload perhaps?
            }, deselect: { (asset: PHAsset) -> Void in
                // User deselected an assets.
                // Do something, cancel upload?
            }, cancel: { (assets: [PHAsset]) -> Void in
                // User cancelled. And this where the assets currently selected.
            }, finish: { (assets: [PHAsset]) -> Void in
                // User finished with these assets
                for asset in assets {
                    let img = self.getAsset(asset)
                    self.images.append(img)
                }
                self.uploadimages()
            }, completion: nil)
        
    }
    
    func getAsset(asset: PHAsset) -> UIImage {
    var image = UIImage()
    let imgManager = PHImageManager.defaultManager()
    let requestOptions = PHImageRequestOptions()
    requestOptions.synchronous = true
        let width  = CGFloat(asset.pixelWidth)
        let height = CGFloat(asset.pixelHeight)
        
    imgManager.requestImageForAsset(asset, targetSize: CGSizeMake(width, height), contentMode: PHImageContentMode.AspectFit, options: requestOptions, resultHandler: { (img, _) in
    image = img!
    })
    return image
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        askForFilename(UIImagePNGRepresentation(image)!)
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func showSimpleAlertWithTitle(title: String, message: String, cancelButtonTitle cancelTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    private func askForFilename(data: NSData) {
        let alertController = UIAlertController(title: "File Name", message: "Please specify the file name.", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler(nil)
        let doneAction = UIAlertAction(title: "Done", style: .Default, handler: {[unowned self](action: UIAlertAction) -> Void in
            let specifiedKey = alertController.textFields!.first!.text!
            if specifiedKey.characters.count == 0 {
                self.showSimpleAlertWithTitle("Error", message: "The file name cannot be empty.", cancelButtonTitle: "OK")
                return
            } else {
                let key: String = "\(self.prefix)\(specifiedKey)"
                self.uploadWithData(data, forKey: key)
                self.reloadobjects()
            }
            })
        alertController.addAction(doneAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func askForDirectoryName() {
        let alertController: UIAlertController = UIAlertController(title: "Directory Name", message: "Please specify the directory name.", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler(nil)
        let doneAction: UIAlertAction = UIAlertAction(title: "Done", style: .Default, handler: {[weak self](action: UIAlertAction) -> Void in
            guard let strongSelf = self else { return }
            let specifiedKey = alertController.textFields!.first!.text!
            if specifiedKey.characters.count == 0 {
                strongSelf.showSimpleAlertWithTitle("Error", message: "The directory name cannot be empty.", cancelButtonTitle: "OK")
                return
            } else {
                let key = "\(strongSelf.prefix)\(specifiedKey)/"
               strongSelf.createFolderForKey(key)
            }
            })
        alertController.addAction(doneAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func uploadLocalContent(localContent: AWSLocalContent) {
        // upload the file
        localContent.uploadWithPinOnCompletion(false, progressBlock: {[weak self](content: AWSLocalContent?, progress: NSProgress?) -> Void in
            guard let strongSelf = self else { return }
            dispatch_async(dispatch_get_main_queue()) {
                // Update the upload UI if it is a new upload and the table is not yet updated
               
                    for uploadContent in strongSelf.manager.uploadingContents {
                        if uploadContent.key == content?.key {
                            let index = strongSelf.manager.uploadingContents.indexOf(uploadContent)!
                            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            //                strongSelf.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                        }
                    }
                }
                     }, completionHandler: {[weak self](content: AWSContent?, error: NSError?) -> Void in
    guard let strongSelf = self else { return }    //strongSelf.updateUploadUI()
    if let error = error {
    print("Failed to upload an object. \(error)")
    strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to upload an object.", cancelButtonTitle: "OK")
    }
        
        })
}
    /*
private func uploadWithData(data: NSData, forKey key: String) {
    let localContent = manager.localContentWithData(data, key: key)
    uploadLocalContent(localContent)
}
    */
    
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.characterAtIndex( Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    
    private func uploadWithData(data: NSData, forKey key: String) {
         messlab.text = "Uploading"
        ActInt.startAnimating()
             let localContent = manager.localContentWithData(data, key: key)
        localContent.uploadWithPinOnCompletion(
            false,
            progressBlock: {[weak self](content: AWSLocalContent?, progress: NSProgress?) -> Void in
                guard let strongSelf = self else { return }
                /* Show progress in UI. */
            },
            completionHandler: {[weak self](content: AWSContent?, error: NSError?) -> Void in
                guard let strongSelf = self else { return }
                if let error = error { 
                    print("Failed to upload an object. \(error)")
                } else {
                     self!.messlab.text = ""
                    print("Object upload complete. ")
            //        self?.reloadobjects()
                }
                self?.ActInt.stopAnimating()
            })
    }
    
    private func uploadimages() {
        ActInt.startAnimating()
        for iimg in images {
            let data = UIImagePNGRepresentation(iimg)!
            let fn = randomString(15)
            let key: String = "\(self.prefix)\(fn)"
            self.uploadWithData(data, forKey: key)
            
        }
     //   ActInt.stopAnimating()
         self.reloadobjects()
    }

private func createFolderForKey(key: String) {
    let localContent = manager.localContentWithData(nil, key: key)
    uploadLocalContent(localContent)
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
    
    private func checkspace() {
        
        if datalimit < diskspace {
             uploadbutton.enabled = false
            self.showSimpleAlertWithTitle("Disk Limit", message: "You have reach your limit", cancelButtonTitle: "OK")
            
        } else {
            uploadbutton.enabled = true
        }
    }
    
    private func downloadObjects() {
        //get all objects/files
        self.diskspace = 0
         messlab.text = "Downloading..."
        ActInt.startAnimating()
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
                        self!.diskspace =  self!.diskspace + content.knownRemoteByteCount
                        
                        self!.tableview.reloadData()
                    }
              }
                 self!.messlab.text = ""
                self?.ActInt.stopAnimating()
            self?.checkspace()
            }
            })
    }
    
    private func reloadobjects() {
    
        ActInt.startAnimating()
        contents.removeAll()
        self.manager.clearCache()
        if (AWSIdentityManager.defaultIdentityManager().loggedIn) {
            downloadObjects()
        }
   //    ActInt.stopAnimating()
       self.tableview.reloadData()
    }
    
    //segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ident = segue.identifier {
            switch ident {
            case "showimages" :
                let showimagesvc = segue.destinationViewController as! showimagesVC
        //        if let indexpath = self.tableview.indexPathForCell(sender as! PhotoCell) {
                    showimagesvc.conrents = self.contents
                    showimagesvc.index = sender as! Int
                    
                
                
            default:
                break
            }
        }
    }
    
    //table view section
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCellAWS") as?  PhotoCellAWS {
            let content = contents[indexPath.row]
            cell.confcell(content, prefix: prefix)
            return cell
        } else
        {
            let cell = PhotoCellAWS()
            
            let content = contents[indexPath.row]
            
           cell.confcell(content, prefix: prefix)
           // cell.titlelab.text = content.key
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("showimages", sender: indexPath.row)
        
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contents.count
        
     }
}


extension AWSContent {
    private func isAudioVideo() -> Bool {
        let lowerCaseKey = self.key.lowercaseString
        return lowerCaseKey.hasSuffix(".mov")
            || lowerCaseKey.hasSuffix(".mp4")
            || lowerCaseKey.hasSuffix(".mpv")
            || lowerCaseKey.hasSuffix(".3gp")
            || lowerCaseKey.hasSuffix(".mpeg")
            || lowerCaseKey.hasSuffix(".aac")
            || lowerCaseKey.hasSuffix(".mp3")
    }
    
    private func isImage() -> Bool {
        let lowerCaseKey = self.key.lowercaseString
        return lowerCaseKey.hasSuffix(".jpg")
            || lowerCaseKey.hasSuffix(".png")
            || lowerCaseKey.hasSuffix(".jpeg")
    }
}
