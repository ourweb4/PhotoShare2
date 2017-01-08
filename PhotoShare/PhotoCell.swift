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
    
    func confcell(content: AWSContent, prefix: String) {
       
               var displayFilename: String! = content.key
        //     if let prefix = self.prefix {
        if displayFilename.characters.count > prefix.characters.count {
            displayFilename = displayFilename.substringFromIndex(prefix.endIndex)
        }
        //   }
        
//      print(displayFilename)
        
        if let name: String! = displayFilename {
        
        self.titlelab.text = name
            content.getRemoteFileURLWithCompletionHandler({ (url: NSURL?, error: NSError?) -> Void in
                guard let url = url else {
                   return
                }
                
                if let data = NSData(contentsOfURL: url) {
                    let img = UIImage(data: data)
                    self.photoimg.image = img
                }

        })
    }
    }

}
