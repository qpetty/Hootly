//
//  HootAPIToCoreData.swift
//  Hootly
//
//  Created by Quinton Petty on 2/16/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import CoreData

class HootAPIToCoreData {
    
    class var managedObjectCon: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.managedObjectContext!
    }
    
    class var hostURL: NSURL? {
        if let hostString = NSBundle.mainBundle().objectForInfoDictionaryKey("Production URL") as? String {
            return NSURL(string: hostString)!
        } else {
            println("could not construct URL in getHoots()")
            return nil
        }
    }
    
    class func getHoots(completed: (Int) -> (Void)) {
        var url: NSURL
        
        if let host = hostURL {
            url = NSURL(string: "hoots?lat=5&long=5&user_id=4", relativeToURL: host)!
        } else {
            println("could not construct URL in getHoots()")
            return
        }

        NSLog("Fetching URL: %@", url)
        
        let request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if (error != nil) {
                NSLog("%@", error)
                completed(0)
                return
            }
            
            var threadMOC = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            threadMOC.parentContext = self.managedObjectCon
            
            if var hootArray = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? Array<Dictionary<String, AnyObject>>{
                
                //Make an Array of ids to then search through core data with
                var idArray = [Int]()
                
                //println(hootArray)
                for hoot in hootArray {
                    if let id = hoot["id"] as? Int {
                        idArray.append(id)
                        //println(id)
                    }
                }
                
                //Prepare fetch request to get all old hoots not in our new list
                var fetchReq = NSFetchRequest(entityName: "Hoot")
                fetchReq.predicate = NSPredicate(format: "NOT (id IN %@)", idArray)
                fetchReq.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

                var fetchError: NSError?
                let hootsToDelete = threadMOC.executeFetchRequest(fetchReq, error: &fetchError) as [Hoot]
                
                if let error = fetchError {
                    println("error exectuting fetch request for hoots to delete")
                    completed(0)
                    return
                }

                //Delete old hoots
                for singleHoot in hootsToDelete {
                    threadMOC.deleteObject(singleHoot)
                }
                
                
                //Prepare fetch request to add new hoots
                fetchReq = NSFetchRequest(entityName: "Hoot")
                fetchReq.predicate = NSPredicate(format: "(id IN %@)", idArray)
                fetchReq.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
                
                let validHoots = threadMOC.executeFetchRequest(fetchReq, error: &fetchError) as [Hoot]
                
                if let error = fetchError {
                    println("error exectuting fetch request for hoots to keep")
                    completed(0)
                    return
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

                            if let tempPhotoURL = NSURL(string: singleHoot["image_path"] as String, relativeToURL: self.hostURL!) {
                                newItem.photoURL = tempPhotoURL
                            }
                        }
                    }
                }
                
                //Save after everything
                threadMOC.save(&fetchError)
                
                if let error = fetchError {
                    println("error saving context in getHoots()")
                    completed(0)
                } else {
                    completed(hootArray.count)
                }
            } else {
                completed(0)
            }
        }
    }
    
    class func postHoot(image: UIImage, comment: String, completed: (success: Bool) -> (Void)) {
        var url: NSURL
        
        if let host = hostURL {
            url = NSURL(string: "comments", relativeToURL: host)!
        } else {
            println("could not construct URL in getHoots()")
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        var postBody = NSMutableData()
        postBody.mp_setInteger(6, forKey: "user_id")
        postBody.mp_setFloat(5, forKey: "lat")
        postBody.mp_setFloat(5, forKey: "long")
        postBody.mp_setString(comment, forKey: "hoot_text")
        postBody.mp_setJPEGImage(image, withQuality: 1.0, forKey: "image")
        
        request.setValue(postBody.KIMultipartContentType, forHTTPHeaderField: "Content-Type")
        postBody.mp_prepareForRequest()
        request.HTTPBody = postBody
        
        self.genericURLConnectionFromRequest(request, completed: completed)
    }
    
    class func postComment(comment: String, hootID: Int, completed: (success: Bool) -> (Void)) {
        var url: NSURL
        
        if let host = hostURL {
            url = NSURL(string: "comments", relativeToURL: host)!
        } else {
            println("could not construct URL in getHoots()")
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        var postBody = NSMutableData()
        postBody.mp_setInteger(6, forKey: "user_id")
        postBody.mp_setInteger(Int32(hootID), forKey: "post_id")
        postBody.mp_setString(comment, forKey: "text")
        
        request.setValue(postBody.KIMultipartContentType, forHTTPHeaderField: "Content-Type")
        postBody.mp_prepareForRequest()
        request.HTTPBody = postBody
        
        NSLog("Posting comment for hoot %d to URL: %@", hootID, url)
        
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