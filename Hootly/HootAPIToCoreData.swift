//
//  HootAPIToCoreData.swift
//  Hootly
//
//  Created by Quinton Petty on 2/16/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class HootAPIToCoreData {
    
    class var managedObjectCon: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.managedObjectContext!
    }
    
    class var hootID: String {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let hootID = appDelegate.hootlyID {
            return hootID
        } else {
            return "4"
        }
    }
    
    class var hostURL: NSURL? {
        if let hostString = NSBundle.mainBundle().objectForInfoDictionaryKey("Production URL") as? String {
            return NSURL(string: hostString)!
        } else {
            NSLog("could not construct URL in getHoots()")
            return nil
        }
    }
    
    class var coordinates: CLLocationCoordinate2D? {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let manager = appDelegate.locationManager

        if manager.location == nil {
            return nil
        }
        return manager.location.coordinate
    }
    
    class func getHootID(completed: (id: String?) -> (Void)) {
        var url: NSURL
        
        if let host = hostURL {
            url = NSURL(string: "newuser", relativeToURL: host)!
        } else {
            NSLog("could not construct URL in getHoots()")
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        NSLog("Posting hoot to URL: %@", url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if (error != nil) {
                NSLog("%@", error)
                completed(id: nil)
                return
            }
            
            if var hootArray = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? Dictionary<String, String>{
                completed(id: hootArray["user_id"])
            } else {
                completed(id: nil)
            }
        }
    }
    
    class func getMyHootLoot(completed: (loot: Int?) -> (Void)) {
        var url: NSURL
        
        if let host = hostURL {
            let urlPath = "hootloot?user_id=\(self.hootID)"
            url = NSURL(string: urlPath, relativeToURL: host)!
        } else {
            NSLog("could not construct URL in getHoots()")
            completed(loot: nil)
            return
        }
        
        NSLog("GETting URL: %@", url)
        
        let request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if (error != nil) {
                NSLog("%@", error)
                completed(loot: nil)
                return
            }
            
            println(NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil))
            
            if var hootArray = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? Dictionary<String, Int>{
                if let loot = hootArray["hootloot"] {
                    completed(loot: loot)
                    return;
                }
            }
            
            completed(loot: nil)
        }
    }
    
    class func getMyHoots(completed: (Int) -> (Void)) {
        var url: NSURL
        
        let coord = self.coordinates
        if coord == nil {
            NSLog("could not get location coordinates")
            return
        }
        
        if let host = hostURL {
            let urlPath = "myhoots?user_id=\(self.hootID)"
            url = NSURL(string: urlPath, relativeToURL: host)!
        } else {
            NSLog("could not construct URL in getHoots()")
            return
        }
        
        NSLog("GETting URL: %@", url)
        
        let request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if (error != nil) {
                NSLog("%@", error)
                completed(0)
                return
            }
            
            if var hootArray = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? Array<Dictionary<String, AnyObject>>{
                completed(self.addHootsToCoreData(hootArray, removeOthers: false))
            } else {
                completed(0)
            }
            
        }
    }
    
    class func getSingleHoot(singleHootID: Int, completed: (Int) -> (Void)) {
        var url: NSURL
        
        let coord = self.coordinates
        if coord == nil {
            NSLog("could not get location coordinates")
            return
        }
        
        if let host = hostURL {
            let urlPath = "hoot?user_id=\(self.hootID)&post_id=\(singleHootID)"
            url = NSURL(string: urlPath, relativeToURL: host)!
        } else {
            NSLog("could not construct URL in getHoots()")
            return
        }
        
        NSLog("GETting URL: %@", url)
        
        let request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if (error != nil) {
                NSLog("%@", error)
                completed(0)
                return
            }
            
            if var hoot = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? Dictionary<String, AnyObject>{
                completed(self.addHootsToCoreData([hoot], removeOthers: false))
            } else {
                completed(0)
            }
            
        }

    }
    
    class func getHoots(completed: (Int) -> (Void)) {
        var url: NSURL
        
        let coord = self.coordinates
        if coord == nil {
            NSLog("could not get location coordinates")
            return
        }
        
        if let host = hostURL {
            let urlPath = "hoots?user_id=\(self.hootID)&lat=\(coord!.latitude)&long=\(coord!.longitude)"
            url = NSURL(string: urlPath, relativeToURL: host)!
        } else {
            NSLog("could not construct URL in getHoots()")
            return
        }

        NSLog("GETting URL: %@", url)
        
        let request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if (error != nil) {
                NSLog("%@", error)
                completed(0)
                return
            }
            
            if var hootArray = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? Array<Dictionary<String, AnyObject>>{
                completed(self.addHootsToCoreData(hootArray, removeOthers: true))
            } else {
                completed(0)
            }
            
        }
    }
    
    class func addHootsToCoreData(hootArray: Array<Dictionary<String, AnyObject>>, removeOthers: Bool) -> Int {
        
        var threadMOC = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        threadMOC.parentContext = self.managedObjectCon
        
        //Make an Array of ids to then search through core data with
        var idArray = [Int]()
        
        //println(hootArray)
        for hoot in hootArray {
            if let id = hoot["id"] as? Int {
                idArray.append(id)
                //println(id)
            }
        }
        
        if removeOthers == true {
            removeHootsWithIDs(idArray)
        }

        var fetchError: NSError?
        
        //Prepare fetch request to add new hoots
        let fetchReq = NSFetchRequest(entityName: "Hoot")
        fetchReq.predicate = NSPredicate(format: "(id IN %@)", idArray)
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let validHoots = threadMOC.executeFetchRequest(fetchReq, error: &fetchError) as [Hoot]
        
        if let error = fetchError {
            NSLog("error exectuting fetch request for hoots to keep")
            return 0
        }
        
        for singleHoot in hootArray {
            if let id = singleHoot["id"] as? Int {
                
                var foundExistingID = false
                for oldHoot in validHoots {
                    if oldHoot.id == id {
                        foundExistingID = true
                        
                        if let value = singleHoot["hootloot"] as? NSNumber {
                            if (value != oldHoot.rating) {
                                oldHoot.rating = singleHoot["hootloot"] as NSNumber
                            }
                        }
                        
                        if let value = singleHoot["num_comments"] as? NSNumber {
                            if (value != oldHoot.replies) {
                                oldHoot.replies = singleHoot["num_comments"] as NSNumber
                            }
                        }
                        
                        if let value = singleHoot["requester_vote"] as? NSNumber {
                            if (value != oldHoot.voted) {
                                oldHoot.voted = singleHoot["requester_vote"] as NSNumber
                            }
                        }
                        break
                    }
                }
                
                //Create new Hoot if we didnt find it 
                if foundExistingID == false {
                    var newItem = NSEntityDescription.insertNewObjectForEntityForName("Hoot", inManagedObjectContext: threadMOC) as Hoot
                    newItem.id = id
                    newItem.time = NSDate(timeIntervalSince1970: singleHoot["timestamp"]! as NSTimeInterval)
                    newItem.comment = singleHoot["hoot_text"] as String
                    newItem.rating = singleHoot["hootloot"] as NSNumber
                    newItem.replies = singleHoot["num_comments"] as NSNumber
                    newItem.voted = singleHoot["requester_vote"] as NSNumber
                    newItem.myHoot = singleHoot["mine"] as Bool
                    
                    if let tempPhotoURL = NSURL(string: singleHoot["image_path"] as String, relativeToURL: self.hostURL!) {
                        newItem.photoURL = tempPhotoURL
                    }
                }
            }
        }
        
        //Save after everything
        threadMOC.save(&fetchError)
        
        if let error = fetchError {
            NSLog("error saving context in getHoots()")
            return 9
        }


        return hootArray.count
    }

    class func removeHootsWithIDs(idArray: [Int]) {
        var threadMOC = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        threadMOC.parentContext = self.managedObjectCon
        
        //Prepare fetch request to get all old hoots not in our new list
        var fetchReq = NSFetchRequest(entityName: "Hoot")
        fetchReq.predicate = NSPredicate(format: "(NOT(id IN %@)) && (myHoot = false)", idArray)
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        var fetchError: NSError?
        let hootsToDelete = threadMOC.executeFetchRequest(fetchReq, error: &fetchError) as [Hoot]
        
        if let error = fetchError {
            NSLog("error exectuting fetch request for hoots to delete")
            return
        }
        
        //Delete old hoots
        for singleHoot in hootsToDelete {
            
            if let urlToDelete = singleHoot.photoURL as? NSURL {
                if urlToDelete.fileURL == true {
                    NSFileManager.defaultManager().removeItemAtURL(urlToDelete, error: nil)
                }
            }
            
            threadMOC.deleteObject(singleHoot)
        }
        
        //Save after everything
        threadMOC.save(&fetchError)
        
        if let error = fetchError {
            NSLog("error saving context in removeHootsWithIDs()")
        }
    }
    
    class func fetchCommentsForHoot(hoot: Hoot?, completed: (success: Bool) -> (Void)) {
        
        if hoot == nil {
            completed(success: false)
            return
        }
        
        let path = "comments?user_id=\(self.hootID)&post_id=\(hoot!.id)"
        
        if let commentURL = NSURL(string: path, relativeToURL: HootAPIToCoreData.hostURL) {
            let request = NSURLRequest(URL: commentURL)
            NSLog("GETting URL: %@", commentURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                
                if (error != nil) {
                    NSLog("%@", error)
                    completed(success: false)
                    return
                }
                
                //println("Got response: \(response)")
                
                if var commentArray = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? Array<Dictionary<String, AnyObject>> {
                    //println("array: \(commentArray)")
                    
                    self.addCommentsToHoot(hoot!, commentArray: commentArray)
                }
                
                completed(success: true)
            })
        }
    }
    
    class func addCommentsToHoot(hoot: Hoot, commentArray: Array<Dictionary<String, AnyObject>>) {
        var threadMOC = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        threadMOC.parentContext = hoot.managedObjectContext
        
        let backgroundContextSelf = threadMOC.objectWithID(hoot.objectID) as Hoot
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
            if let value = singleComment["timestamp"] as? NSNumber {
                newComment.time = NSDate(timeIntervalSince1970: value as NSTimeInterval)
            } else {
                newComment.time = NSDate()
            }
            
            newComment.hoot = backgroundContextSelf
            existingComments.addObject(newComment)
            
        }
        
        backgroundContextSelf.replies = commentArray.count
        
        //TODO: Check value
        threadMOC.save(nil)
    }
    
    class func reportHoot(hoot: Hoot?, completed: (success: Bool) -> (Void)) {
        var url: NSURL
        
        if hoot == nil {
            completed(success: false)
            return
        }
        
        if let host = hostURL {
            url = NSURL(string: "hoot?user_id=\(self.hootID)&post_id=\(hoot!.id)", relativeToURL: host)!
        } else {
            NSLog("could not construct URL in getHoots()")
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        
        NSLog("Reporting hoot(%@) to URL: %@", hoot!.id, url)
        
        self.genericURLConnectionFromRequest(request, completed: completed)
    }
    
    class func postPUSHToken(id: String, token: String, completed: (success: Bool) -> (Void)) {
        var url: NSURL
        
        if let host = hostURL {
            url = NSURL(string: "newtoken", relativeToURL: host)!
        } else {
            NSLog("could not construct URL in getHoots()")
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        var postBody = NSMutableData()
        postBody.mp_setString(id, forKey: "user_id")
        postBody.mp_setString(token, forKey: "token")
        
        request.setValue(postBody.KIMultipartContentType, forHTTPHeaderField: "Content-Type")
        postBody.mp_prepareForRequest()
        request.HTTPBody = postBody
        
        NSLog("POSTing token(%@) to URL: %@", token, url)
        
        self.genericURLConnectionFromRequest(request, completed: completed)
    }
    
    class func postHoot(image: UIImage, comment: String, delegate: NSURLConnectionDataDelegate) {
        var url: NSURL
        
        let coord = self.coordinates
        if coord == nil {
            NSLog("could not get location coordinates")
            return
        }
        
        if let host = hostURL {
            url = NSURL(string: "hoots", relativeToURL: host)!
        } else {
            NSLog("could not construct URL in getHoots()")
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        var postBody = NSMutableData()
        postBody.mp_setString(self.hootID, forKey: "user_id")
        postBody.mp_setFloat(Float(coord!.latitude), forKey: "lat")
        postBody.mp_setFloat(Float(coord!.longitude), forKey: "long")
        postBody.mp_setString(comment, forKey: "hoot_text")
        postBody.mp_setJPEGImage(image, withQuality: 1.0, forKey: "image")
        
        request.setValue(postBody.KIMultipartContentType, forHTTPHeaderField: "Content-Type")
        postBody.mp_prepareForRequest()
        request.HTTPBody = postBody
        
        NSLog("POSTing hoot to URL: %@", url)
        
        let conn = NSURLConnection(request: request, delegate: delegate, startImmediately: true)
        //self.genericURLConnectionFromRequest(request, completed: completed)
    }
    
    class func postComment(comment: String, hootID: Int, delegate: NSURLConnectionDataDelegate) {
        var url: NSURL
        
        if let host = hostURL {
            url = NSURL(string: "comments", relativeToURL: host)!
        } else {
            NSLog("could not construct URL in getHoots()")
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        var postBody = NSMutableData()
        postBody.mp_setString(self.hootID, forKey: "user_id")
        postBody.mp_setInteger(Int32(hootID), forKey: "post_id")
        postBody.mp_setString(comment, forKey: "text")
        
        request.setValue(postBody.KIMultipartContentType, forHTTPHeaderField: "Content-Type")
        postBody.mp_prepareForRequest()
        request.HTTPBody = postBody
        
        NSLog("POSTing comment for hoot %d to URL: %@", hootID, url)
        
        let conn = NSURLConnection(request: request, delegate: delegate, startImmediately: true)
        //self.genericURLConnectionFromRequest(request, completed: completed)
    }
    
    class func postHootUpVote(id: Int, completed: (success: Bool) -> (Void)) {
        postVote("hootsup", hootID: id, idName: "post_id", completed: completed)
    }
    
    class func postHootDownVote(id: Int, completed: (success: Bool) -> (Void)) {
        postVote("hootsdown", hootID: id, idName: "post_id", completed: completed)
    }
    
    class func postCommentUpVote(id: Int, completed: (success: Bool) -> (Void)) {
        postVote("commentsup", hootID: id, idName: "comment_id", completed: completed)
    }
    
    class func postCommentDownVote(id: Int, completed: (success: Bool) -> (Void)) {
        postVote("commentsdown", hootID: id, idName: "comment_id", completed: completed)
    }
    
    class func postVote(type: String, hootID: Int, idName: String, completed: (success: Bool) -> (Void)) {
        var url: NSURL
        
        if let host = hostURL {
            url = NSURL(string: type, relativeToURL: host)!
        } else {
            NSLog("could not construct URL in getHoots()")
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        var postBody = NSMutableData()
        postBody.mp_setString(self.hootID, forKey: "user_id")
        postBody.mp_setInteger(Int32(hootID), forKey: idName)
        
        request.setValue(postBody.KIMultipartContentType, forHTTPHeaderField: "Content-Type")
        postBody.mp_prepareForRequest()
        request.HTTPBody = postBody
        
        NSLog("POSTing %@ for hoot %d to URL: %@", type, hootID, url)
        
        self.genericURLConnectionFromRequest(request, completed: completed)
    }
    
    // MARK: - Convienence Functions (I wish these could be private class methods)
    
    class func genericURLConnectionFromRequest(request: NSURLRequest, completed: (success: Bool) -> (Void)) {
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if (error != nil) {
                NSLog("%@", error)
                completed(success: false)
                return
            }
            
            let str = NSString(data: data, encoding: NSUTF8StringEncoding)
            NSLog("Response: %@", str!)
            completed(success: true)
        }
    }
}