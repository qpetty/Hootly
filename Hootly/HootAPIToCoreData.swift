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
    
    
    class func getHoots(completed: (Int) -> (Void)) {
        var url: NSURL
        var host: NSURL
        
        if let hostString = NSBundle.mainBundle().objectForInfoDictionaryKey("Production URL") as? String {
            host = NSURL(string: hostString)!
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
                let hootsToDelete = self.managedObjectCon.executeFetchRequest(fetchReq, error: &fetchError) as [Hoot]
                
                if let error = fetchError {
                    println("error exectuting fetch request for hoots to delete")
                    completed(0)
                    return
                }

                //Delete old hoots
                for singleHoot in hootsToDelete {
                    self.managedObjectCon.deleteObject(singleHoot)
                }
                
                
                //Prepare fetch request to add new hoots
                fetchReq = NSFetchRequest(entityName: "Hoot")
                fetchReq.predicate = NSPredicate(format: "(id IN %@)", idArray)
                fetchReq.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
                
                let validHoots = self.managedObjectCon.executeFetchRequest(fetchReq, error: &fetchError) as [Hoot]
                
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
                                break
                            }
                        }
                        
                        //Create new Hoot if we didnt find it
                        if foundExistingID == false {
                            var newItem = NSEntityDescription.insertNewObjectForEntityForName("Hoot", inManagedObjectContext: self.managedObjectCon) as Hoot
                            newItem.id = id
                            newItem.time = NSDate(timeIntervalSince1970: singleHoot["timestamp"]! as NSTimeInterval)
                            newItem.comment = singleHoot["hoot_text"] as String
                            newItem.rating = singleHoot["hootloot"] as NSNumber
                            newItem.replies = singleHoot["num_comments"] as NSNumber

                            if let tempPhotoURL = NSURL(string: singleHoot["image_path"] as String, relativeToURL: host) {
                                newItem.photoURL = tempPhotoURL
                            }
                        }
                    }
                }
                
                //Save after everything
                self.managedObjectCon.save(&fetchError)
                
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
}