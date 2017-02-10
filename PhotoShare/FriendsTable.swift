//
//  FriendsTable.swift
//  PhotoShare
//
//  Created by Bill Banks on 2/2/17.
//  Copyright © 2017 Ourweb.net. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class FriendsTable: NSObject, Table {
    
    var tableName: String
    var partitionKeyName: String
    var partitionKeyType: String
    var sortKeyName: String?
    var sortKeyType: String?
    var model: AWSDynamoDBObjectModel
    var indexes: [Index]
    var orderedAttributeKeys: [String] {
        return produceOrderedAttributeKeys(model)
    }
    var tableDisplayName: String {
        
        return "friends"
    }
    
    override init() {
        
        model = Friends()
        
        tableName = model.classForCoder.dynamoDBTableName()
        partitionKeyName = model.classForCoder.hashKeyAttribute()
        partitionKeyType = "String"
        indexes = [
            
            FriendsPrimaryIndex(userna: ""),
            
            FriendsFriendUsername(fri: ""),
        ]
        if (model.classForCoder.respondsToSelector("rangeKeyAttribute")) {
            sortKeyName = model.classForCoder.rangeKeyAttribute!()
            sortKeyType = "String"
        }
        super.init()
    }
    
    func addfriend(friend: String) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let addfriend = Friends()
        addfriend._userId = AWSIdentityManager.defaultIdentityManager().identityId!
        addfriend._username = AWSIdentityManager.defaultIdentityManager().userName!
        addfriend._friend = friend
        objectMapper.save(addfriend)
        
   
    }
    
    func deletefriend(friend: String) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let delfriend = Friends()
        delfriend._userId = AWSIdentityManager.defaultIdentityManager().identityId!
        delfriend._username = AWSIdentityManager.defaultIdentityManager().userName!
        delfriend._friend = friend
        objectMapper.remove(delfriend, completionHandler: {(error: NSError?) -> Void in
            
            if error != nil {
                print("Friend delete error: \(error)")
            } else {
                print("Friend Deletedf")
            }
            
        })
        
    }
    
    func getshares() -> [Friends]{
        var list = [Friends]()
        
        let fech = FriendsPrimaryIndex(userna: AWSIdentityManager.defaultIdentityManager().userName!)
        
        
        
        fech.queryWithPartitionKeyWithCompletionHandler({ ( reponse: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            
            if error == nil {
                
                for item in reponse!.items  {
                    let rec = item as! Friends
                    list.append(rec)
                    
                    
                }
                
            }
            
            
        })

        
        return list
        
    }
    
    func getfriends() -> [Friends]{
        var list = [Friends]()
        
        let fech = FriendsFriendUsername(fri: AWSIdentityManager.defaultIdentityManager().userName!)
        
        fech.queryWithPartitionKeyWithCompletionHandler({ ( reponse: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            
            if error == nil {
                
                for item in reponse!.items  {
                    let rec = item as! Friends
                    list.append(rec)
                    
                    
                }
                
            }
            
            
        })
        
        
        return list
        
    }
    /**
     * Converts the attribute name from data object format to table format.
     *
     * - parameter dataObjectAttributeName: data object attribute name
     * - returns: table attribute name
     */
    
    func tableAttributeName(dataObjectAttributeName: String) -> String {
        return Friends.JSONKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
    }
    
    func getItemDescription() -> String {
        return "Find Item with userId = \(AWSIdentityManager.defaultIdentityManager().identityId!) and username = \("demo-username-500000")."
    }
    
    func getItemWithCompletionHandler(completionHandler: (response: AWSDynamoDBObjectModel?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        objectMapper.load(Friends.self, hashKey: AWSIdentityManager.defaultIdentityManager().identityId!, rangeKey: "demo-username-500000", completionHandler: {(response: AWSDynamoDBObjectModel?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(response: response, error: error)
            })
        })
    }
    
    func scanDescription() -> String {
        return "Show all items in the table."
    }
    
    func scanWithCompletionHandler(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 5
        
        objectMapper.scan(Friends.self, expression: scanExpression, completionHandler: {(response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(response: response, error: error)
            })
        })
    }
    
    
    func removeSampleDataWithCompletionHandler(completionHandler: (errors: [NSError]?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = ["#userId": "userId"]
        queryExpression.expressionAttributeValues = [":userId": AWSIdentityManager.defaultIdentityManager().identityId!,]
        
        objectMapper.query(Friends.self, expression: queryExpression) { (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            if let error = error {
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(errors: [error]);
                })
            } else {
                var errors: [NSError] = []
                let group: dispatch_group_t = dispatch_group_create()
                for item in response!.items {
                    dispatch_group_enter(group)
                    objectMapper.remove(item, completionHandler: {(error: NSError?) -> Void in
                        if error != nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                errors.append(error!)
                            })
                        }
                        dispatch_group_leave(group)
                    })
                }
                dispatch_group_notify(group, dispatch_get_main_queue(), {
                    if errors.count > 0 {
                        completionHandler(errors: errors)
                    }
                    else {
                        completionHandler(errors: nil)
                    }
                })
            }
        }
    }
    
    
    func removeItem(item: AWSDynamoDBObjectModel, completionHandler: (error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        objectMapper.remove(item, completionHandler: {(error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(error: error)
            })
        })
    }
}

class FriendsPrimaryIndex: NSObject, Index {
    
    var username = ""
    
    var indexName: String? {
        return nil
    }
    
    init(userna: String) {
        username = userna
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
            QueryWithPartitionKeyAndSortKey,
        ]
    }
    
    func queryWithPartitionKeyDescription() -> String {
        return "Find all items with userId = \(AWSIdentityManager.defaultIdentityManager().identityId!)."
    }
    
    func queryWithPartitionKeyWithCompletionHandler(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = ["#userId": "userId",]
        queryExpression.expressionAttributeValues = [":userId": AWSIdentityManager.defaultIdentityManager().identityId!,]
        
        objectMapper.query(Friends.self, expression: queryExpression, completionHandler: {(response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(response: response, error: error)
            })
        })
    }
    
    func queryWithPartitionKeyAndSortKeyDescription() -> String {
        return "Find all items with userId = \(AWSIdentityManager.defaultIdentityManager().identityId!) and username < \(username)."
    }
    
    func queryWithPartitionKeyAndSortKeyWithCompletionHandler(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        
        queryExpression.keyConditionExpression = "#userId = :userId AND #username < :username"
        queryExpression.expressionAttributeNames = [
            "#userId": "userId",
            "#username": "username",
        ]
        queryExpression.expressionAttributeValues = [
            ":userId": AWSIdentityManager.defaultIdentityManager().identityId!,
            ":username": "\(username)",
        ]
        
        
        objectMapper.query(Friends.self, expression: queryExpression, completionHandler: {(response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(response: response, error: error)
            })
        })
    }
    
}

class FriendsFriendUsername: NSObject, Index {
    
    var friend = ""
    
    
    var indexName: String? {
        
        return "friend-username"
    }
    
    init(fri : String) {
        friend = fri
    }
    
    func supportedOperations() -> [String] {
        return [
            QueryWithPartitionKey,
            QueryWithPartitionKeyAndSortKey,
        ]
    }
    
    func queryWithPartitionKeyDescription() -> String {
        return "Find all items with friend = \(friend)."
    }
    
    func queryWithPartitionKeyWithCompletionHandler(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        
        
        queryExpression.indexName = "friend-username"
        queryExpression.keyConditionExpression = "#friend = :friend"
        queryExpression.expressionAttributeNames = ["#friend": "friend",]
        queryExpression.expressionAttributeValues = [":friend": friend,]
        
        objectMapper.query(Friends.self, expression: queryExpression, completionHandler: {(response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(response: response, error: error)
            })
        })
    }
    
    func queryWithPartitionKeyAndSortKeyDescription() -> String {
        return "Find all items with friend = \("demo-friend-3") and username < \("demo-username-500000")."
    }
    
    func queryWithPartitionKeyAndSortKeyWithCompletionHandler(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        
        
        queryExpression.indexName = "friend-username"
        queryExpression.keyConditionExpression = "#friend = :friend AND #username < :username"
        queryExpression.expressionAttributeNames = [
            "#friend": "friend",
            "#username": "username",
        ]
        queryExpression.expressionAttributeValues = [
            ":friend": "demo-friend-3",
            ":username": "demo-username-500000",
        ]
        
        
        objectMapper.query(Friends.self, expression: queryExpression, completionHandler: {(response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(response: response, error: error)
            })
        })
    }
    
}
