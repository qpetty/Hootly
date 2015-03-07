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
import CoreLocation

class ViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {
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
        } else {
            NSLog("Expected UISegementedControl")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        promptForLocation()
        
        let manager = appDelegate.locationManager
        manager.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refreshAndFetchData", forControlEvents: .ValueChanged)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        let mess = "changed location authorization to"
        switch status {
        case .Authorized:
            NSLog("%@: Authorized", mess)
        case .AuthorizedWhenInUse:
            NSLog("%@: AuthorizedWhenInUse", mess)
            beginRefreshing()
        case .Denied:
            NSLog("%@: Denied", mess)
        case .NotDetermined:
            NSLog("%@: NotDetermined", mess)
        case .Restricted:
            NSLog("%@: Restricted", mess)
        }
    }
    
    func beginRefreshing() {
        refreshControl?.beginRefreshing()
        self.fetchResultsFromCoreData(true)
        refreshAndFetchData()
        tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl!.frame.size.height), animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO: Might not be the best place for this but we'll try it here for a while
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "managedObjectContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func managedObjectContextDidSave(aNotification: NSNotification) {
        NSLog("managed object context did save")
        if(NSThread.isMainThread() == false) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.managedObjectContextDidSave(aNotification)
            })
        }

        // if a context other than the main context has saved, merge the changes
        if(aNotification.object as? NSManagedObjectContext != managedObjectContext) {
            NSLog("merging changes")
            managedObjectContext?.mergeChangesFromContextDidSaveNotification(aNotification)
        }
    }
    
    func promptForLocation() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let manager = appDelegate.locationManager

        if CLLocationManager.authorizationStatus() == .NotDetermined && CLLocationManager.locationServicesEnabled() {
            if manager.respondsToSelector("requestWhenInUseAuthorization") {
                NSLog("asking for location permission")
                manager.requestWhenInUseAuthorization()
            }
        }
        manager.startUpdatingLocation()
    }
    
    func refreshAndFetchData() {
        
        switch CLLocationManager.authorizationStatus() {
        case .Authorized, .AuthorizedWhenInUse:
            HootAPIToCoreData.getHoots { (addedHoots: Int) -> (Void) in
                self.refreshControl?.endRefreshing()
                return
            }
        case .NotDetermined:
            promptForLocation()
        case .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "In order to use retrieve nearby hoots, please open this app's settings and set location access to 'While Using the App'.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func fetchResultsFromCoreData(sortedByDate: Bool) {
        let fetchReq = NSFetchRequest(entityName: "Hoot")
        
        if sortedByDate == true {
            let sortDes = NSSortDescriptor(key: "time", ascending: false)
            fetchReq.sortDescriptors = [sortDes]
        } else {
            let sortDes = NSSortDescriptor(key: "rating", ascending: false)
            fetchReq.sortDescriptors = [sortDes]
        }
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchReq, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        
        if fetchedResultsController?.performFetch(nil) == false {
            NSLog("fetch failed")
            return
        }
        
        NSLog("fetch succeeded: ordered by time -> \(sortedByDate)")
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        
        if(tableView.numberOfRowsInSection(0) > 0) {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        //println("called will change content")
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            NSLog("Unknown NSFetchedResultsChangeType in ViewController")
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? HootCell {
                cell.setHoot(cell.hoot!)
            }
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            NSLog("Unknown NSFetchedResultsChangeType in ViewController")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: - NSTableViewDelegate
    
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
        NSLog("nothing picked")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "DetailHoot":
            let dest = segue.destinationViewController as SingleHootViewController
            let cell = sender as HootCell
            dest.hoot = cell.hoot
            dest.hootImage = cell.photo?.image
            
            HootAPIToCoreData.fetchCommentsForHoot(dest.hoot, completed: { (success) -> (Void) in
                //Can't pass in nil instead of a closure so we just won't do anything here
            })
            
            tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: true)
            
        case "Camera":
            let dest = segue.destinationViewController as UIImagePickerController
            dest.delegate = self
            dest.sourceType = .Camera
            dest.allowsEditing = true
            dest.cameraFlashMode = .Off
            dest.mediaTypes = [kUTTypeImage]
            
        default:
            NSLog("unrecognized segue")
        }
    }
}

