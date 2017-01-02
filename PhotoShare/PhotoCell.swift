//
//  PhotoCell.swift
//  PhotoShare
//
//  Created by Bill Banks on 1/2/17.
//  Copyright © 2017 Ourweb.net. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class PhotoCell: UITableViewCell {

    
    
    @IBOutlet weak var photoimg: UIImageView!
    @IBOutlet weak var titlelab: UILabel!
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func confcell(content: AWSContent) {
       
        content.downloadWithDownloadType(.IfNewerExists, pinOnCompletion: true, progressBlock: {[weak self](content: AWSContent?, progress: NSProgress?) -> Void in
            guard let strongSelf = self else { return }
         //   if strongSelf.contents!.contains( {$0 == content} ) {
                //let row = strongSelf.contents!.indexOf({$0  == content!})!
           //     let indexPath = NSIndexPath(forRow: row, inSection: 1)
                //     strongSelf.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            //}
            }, completionHandler: {[weak self](content: AWSContent?, data: NSData?, error: NSError?) -> Void in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("Failed to download a content from a server. \(error)")
                //    strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to download a content from a server.", cancelButtonTitle: "OK")
                }
                
            })
        titlelab.text = content.key
        photoimg.image = UIImage(data: content.cachedData)
        content.unPin()
    }


}
