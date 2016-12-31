//
//  UserIdentityAccess.swift
//  PhotoShare
//
//  Created by Bill Banks on 12/27/16.
//  Copyright © 2016 Ourweb.net. All rights reserved.
//

//import Foundation
import AWSMobileHubHelper

class UserIdentityAccess {
    
    func getUserIdentity() -> String {
        return AWSIdentityManager.defaultIdentityManager().identityId!
}
    func islogin() -> Bool  {
        return AWSIdentityManager.defaultIdentityManager().loggedIn
    }
}
