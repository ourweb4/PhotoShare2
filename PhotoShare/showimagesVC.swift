//
//  showimagesVC.swift
//  PhotoShare
//
//  Created by Bill Banks on 1/8/17.
//  Copyright © 2017 Ourweb.net. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class showimagesVC: UIViewController {
    
    @IBOutlet weak var mainimg: UIImageView!
    
    var conrents = [AWSContent]()
    var index: Int = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        let content = conrents[index]
        show(content)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func prevbut(sender: AnyObject) {
        if index > 0 {
            let content = conrents[--index]
            show(content)
            
        }
    }

    @IBAction func nextbuxt(sender: AnyObject) {
        if index < conrents.count {
            let content = conrents[++index]
            show(content)
            
        }
    }
    
    @IBAction func removebut(sender: AnyObject) {
        
           let content = conrents[index]
           confirmForRemovingContent(content)
        navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    
    func show(content: AWSContent) {
        if content.cached {
            let data = content.cachedData
            let img = UIImage(data: data)
            mainimg.image  = img
        } else {
            content.getRemoteFileURLWithCompletionHandler({[weak self](url: NSURL?, error: NSError?) -> Void in
                guard let strongSelf = self else { return }
                guard let url = url else {
                    print("Error getting URL for file. \(error)")
                    return
                }
                let data = NSData(contentsOfURL: url)
                let img =  UIImage(data: data!)
                self?.mainimg.image = img
                
                })
        }
    }
    
    
    private func confirmForRemovingContent(content: AWSContent) {
        let alertController = UIAlertController(title: "Confirm", message: "Do you want to delete the content from the server? This cannot be undone.", preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "Yes", style: .Default, handler: {[weak self](action: UIAlertAction) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.removeContent(content)
            })
        alertController.addAction(okayAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func removeContent(content: AWSContent) {
        content.removeRemoteContentWithCompletionHandler({[weak self](content: AWSContent?, error: NSError?) -> Void in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Failed to delete an object from the remote server. \(error)")
                dispatch_async(dispatch_get_main_queue()) {
               //     strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to delete an object from the remote server.", cancelButtonTitle: "OK")
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
              //      strongSelf.showSimpleAlertWithTitle("Object Deleted", message: "The object has been deleted successfully.", cancelButtonTitle: "OK")
                }
            //    strongSelf.refreshContents()
            }
            })
    }
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
