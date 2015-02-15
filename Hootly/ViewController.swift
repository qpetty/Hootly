//
//  ViewController.swift
//  Hootly
//
//  Created by Quinton Petty on 1/24/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var feedTableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController?
    var managedObjectContext:NSManagedObjectContext?
    
    
    var sampleData: [Hoot] = []
    
    let CELL_HEIGHT = 80.0 as CGFloat
    
    override init() {
        super.init()
        self.makeSampleData()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.makeSampleData()
    }
    
    func makeSampleData() {
        var sample = Hoot(userID: "Brandon", photo: UIImage(named: "hoot1"), comment: "This is a super duper super optimus prime long comment", replies: 5, time: "1", rating: 8)
        sampleData.append(sample)
        
        sample = Hoot(userID: "Krisna", photo: UIImage(named: "hoot2"), comment: "This is a longer comment", replies: 5, time: "10", rating: 8)
        sampleData.append(sample)
        
        sampleData.sort {$0.time < $1.time}
    }
    
    @IBAction func sortList(sender: AnyObject) {
        if let segment = sender as? UISegmentedControl {
            switch segment.selectedSegmentIndex {
            case 1:
                sampleData.sort {$0.time > $1.time}
            default:
                sampleData.sort {$0.time < $1.time}
            }
            
            feedTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            feedTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        } else {
            println("Expected UISegementedControl")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        if (managedObjectContext != nil) {
            println(managedObjectContext)
            
            var newItem = NSEntityDescription.insertNewObjectForEntityForName("HootItem", inManagedObjectContext: managedObjectContext!) as HootItem
            
            newItem.userID = "Brandon"
            newItem.comment = "This is a super duper super optimus prime long comment"
            newItem.replies = 5
            newItem.time = NSDate()
            newItem.rating = 8
            
            newItem = NSEntityDescription.insertNewObjectForEntityForName("HootItem", inManagedObjectContext: managedObjectContext!) as HootItem
            
            newItem.userID = "Krisna"
            newItem.comment = "This is a longer comment"
            newItem.replies = 5
            newItem.time = NSDate()
            newItem.rating = 8
            
            let fetchReq = NSFetchRequest(entityName: "HootItem")
            let sortDes = NSSortDescriptor(key: "time", ascending: true)
            fetchReq.sortDescriptors = [sortDes]
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchReq, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
            
            if fetchedResultsController?.performFetch(nil) == false {
                println("fetch failed")
            } else {
                println("fetch succeded")
            }
            
            /*
            let fetchRequest = NSFetchRequest(entityName: "HootItem")
            if let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [HootItem] {
                
                NSLog("results size: %lu, userID %@", fetchResults.count, fetchResults[0].userID)
                //println(fetchResults[0].userID)
            }
            */
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width + CELL_HEIGHT
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width + CELL_HEIGHT
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchedResultsController?.sections?.count > 0 {
            if let singleSection = fetchedResultsController?.sections?[section] as? NSFetchedResultsSectionInfo {
                return singleSection.numberOfObjects
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = feedTableView.dequeueReusableCellWithIdentifier("Hoot", forIndexPath: indexPath) as HootCell
        
        if let singleHoot = fetchedResultsController?.objectAtIndexPath(indexPath) as? HootItem {
            cell.setHoot(singleHoot)
        }
        
        return cell
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("NewHoot") as NewHootViewController
        vc.image = image
        
        dismissViewControllerAnimated(true, completion: { () -> Void in
            self.presentViewController(vc, animated: true, completion: nil)
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("nothing picked")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "DetailHoot":
            let dest = segue.destinationViewController as SingleHootViewController
            let cell = sender as HootCell
            //dest.hoot = cell.hoot
            
            feedTableView.deselectRowAtIndexPath(feedTableView.indexPathForSelectedRow()!, animated: true)
            
        case "Camera":
            let dest = segue.destinationViewController as UIImagePickerController
            dest.delegate = self
            dest.sourceType = .Camera
            dest.allowsEditing = true
            dest.cameraFlashMode = .Off
            dest.mediaTypes = [kUTTypeImage]
            
        default:
            println("unrecognized segue")
        }
    }
}

