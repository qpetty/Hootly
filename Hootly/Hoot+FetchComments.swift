//
//  Hoot+FetchComments.swift
//  Hootly
//
//  Created by Quinton Petty on 2/24/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import CoreData

extension Hoot {
    func fetchComments() {
        
        let path = "comments?post_id=\(self.id)&user_id=4"
        
        if let commentURL = NSURL(string: path, relativeToURL: HootAPIToCoreData.hostURL) {
            let request = NSURLRequest(URL: commentURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                
                if (error != nil) {
                    NSLog("%@", error)
                    return
                }
                
                println("Got response: \(response)")
                
                if var commentArray = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? Array<Dictionary<String, AnyObject>> {
                    println("array: \(commentArray)")
                    
                    self.addCommentsToHoot(commentArray)
                }
                
            })
        }
    }
    
    func addCommentsToHoot(commentArray: Array<Dictionary<String, AnyObject>>) {
        var threadMOC = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        threadMOC.parentContext = self.managedObjectContext
        
        let backgroundContextSelf = threadMOC.objectWithID(self.objectID) as Hoot
        var existingComments = backgroundContextSelf.mutableSetValueForKey("comments")
        existingComments.removeAllObjects()
        
        for singleComment in commentArray {
            var newComment = NSEntityDescription.insertNewObjectForEntityForName("HootComment", inManagedObjectContext: threadMOC) as HootComment
            
            if let value = singleComment["comment_id"] as? NSNumber {
                newComment.id = value
            }
            if let value = singleComment["comment_text"] as? String {
                newComment.text = value
            }
            if let value = singleComment["score"] as? NSNumber {
                newComment.score = value
            }
            if let value = singleComment["requester_vote"] as? NSNumber {
                newComment.voted = value
            }
            if let value = singleComment["time"] as? NSDate {
                newComment.time = value
            } else {
                newComment.time = NSDate()
            }
            
            newComment.hoot = backgroundContextSelf
            existingComments.addObject(newComment)
            
        }
        
        //TODO: Check value
        threadMOC.save(nil)
    }
}