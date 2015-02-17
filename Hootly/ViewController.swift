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

class ViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var fetchedResultsController: NSFetchedResultsController?
    var managedObjectContext:NSManagedObjectContext?

    let CELL_HEIGHT = 80.0 as CGFloat
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func sortList(sender: AnyObject) {
        if let segment = sender as? UISegmentedControl {
            switch segment.selectedSegmentIndex {
            case 1:
                fetchResultsFromCoreData(false)
            default:
                fetchResultsFromCoreData(true)
            }
            
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        } else {
            println("Expected UISegementedControl")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refreshAndFetchData", forControlEvents: .ValueChanged)
        
        refreshControl?.beginRefreshing()
        refreshAndFetchData()
        tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl!.frame.size.height), animated: true)
    }
    
    func refreshAndFetchData() {
        HootAPIToCoreData.getHoots { (addedHoots: Int) -> (Void) in
            self.fetchResultsFromCoreData(true)
            
            //Just for testing, should remove this along with pictures for final release
            if addedHoots == 0 {
                self.makeSampleData()
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                self.refreshControl?.endRefreshing()
            })
        }
    }
    
    func fetchResultsFromCoreData(sortedByDate: Bool) {
        let fetchReq = NSFetchRequest(entityName: "Hoot")
        
        if sortedByDate == true {
            let sortDes = NSSortDescriptor(key: "time", ascending: true)
            fetchReq.sortDescriptors = [sortDes]
        } else {
            let sortDes = NSSortDescriptor(key: "rating", ascending: false)
            fetchReq.sortDescriptors = [sortDes]
        }
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchReq, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        if fetchedResultsController?.performFetch(nil) == false {
            println("fetch failed")
        } else {
            println("fetch succeeded: ordered by time -> \(sortedByDate)")
        }
    }
    
    func makeSampleData() {
        if (managedObjectContext != nil) {
            println(managedObjectContext)
            
            var newItem = NSEntityDescription.insertNewObjectForEntityForName("Hoot", inManagedObjectContext: managedObjectContext!) as Hoot
            
            newItem.id = 2
            newItem.comment = "This is a super duper super optimus prime long comment"
            newItem.replies = 2
            newItem.time = NSDate()
            newItem.rating = 8
            newItem.photoURL = NSBundle.mainBundle().URLForResource("hoot1", withExtension: "png")!
            
            newItem = NSEntityDescription.insertNewObjectForEntityForName("Hoot", inManagedObjectContext: managedObjectContext!) as Hoot
            
            newItem.id = 7
            newItem.comment = "This is a longer comment"
            newItem.replies = 5
            newItem.time = NSDate()
            newItem.rating = 9
            newItem.photoURL = NSBundle.mainBundle().URLForResource("hoot2", withExtension: "png")!
            
            managedObjectContext?.save(nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width + CELL_HEIGHT
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width + CELL_HEIGHT
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Hoot", forIndexPath: indexPath) as HootCell
        
        if let singleHoot = fetchedResultsController?.objectAtIndexPath(indexPath) as? Hoot {
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
            dest.hoot = cell.hoot
            dest.hootImage = cell.photo?.image
            
            tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: true)
            
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

