//
//  PhotoCellAWS.swift
//  PhotoShare
//
//  Created by Bill Banks on 1/2/17.
//  Copyright © 2017 Ourweb.net. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class PhotoCellAWS: UITableViewCell {

    
    
    @IBOutlet weak var photoimg: UIImageView!
    //@IBOutlet weak var titlelab: UILabel!
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func confcell(content: AWSContent, prefix: String) {
       
               var displayFilename: String! = content.key
        //     if let prefix = self.prefix {
        if displayFilename.characters.count > prefix.characters.count {
            displayFilename = displayFilename.substringFromIndex(prefix.endIndex)
        }
        //   }
        
//      print(displayFilename)
        
        if let name: String! = displayFilename {
        
 //       self.titlelab.text = name
            if content.cached {
            let data = content.cachedData
            let img = UIImage(data: data)
            photoimg.image  = img
            } else {
                content.getRemoteFileURLWithCompletionHandler({[weak self](url: NSURL?, error: NSError?) -> Void in
                    guard let strongSelf = self else { return }
                    guard let url = url else {
                        print("Error getting URL for file. \(error)")
                        return
                    }
                    let data = NSData(contentsOfURL: url)
                    if  let img =  UIImage(data: data!) {
                        self!.photoimg.image = img
                    }
      
                })
            }
            
        }
    }

}
