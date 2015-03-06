//
//  SingleHootViewController.swift
//  Hootly
//
//  Created by Quinton Petty on 1/31/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SingleHootViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, CommentFormProtocol {
    var hoot: Hoot?
    var hootImage: UIImage?
    var fetchedResultsController: NSFetchedResultsController?
    var managedObjectContext:NSManagedObjectContext?
    
    // Create blur effect view
    var blurEffectView: UIVisualEffectView?
    
    @IBOutlet weak var commentForm: CommentFormView!
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var commentTable: UITableView!
    @IBOutlet weak var keyboardHeight: NSLayoutConstraint!
    @IBOutlet weak var formHeight: NSLayoutConstraint!
    
    let CELL_HEIGHT = 80.0 as Double
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change color of Navigation title to white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        // Create the desired blur effect
        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        
        // Add and set up blurEffect to blurEffectView
        self.blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.blurEffectView?.frame = photo.bounds
        self.blurEffectView?.alpha = 0
        self.photo.addSubview(blurEffectView!)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        commentForm.delegate = self
        
        fetchResultsFromCoreData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        photo.image = hootImage
        
        commentTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboard:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardAway:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func scrollTableViewToBottom() {
        let bottomOffset = CGPoint(x: 0, y: self.commentTable.contentSize.height - self.commentTable.bounds.size.height)
        self.commentTable.setContentOffset(bottomOffset, animated: false)
    }
    
    func keyboard(aNotification: NSNotification) {

        if let info = aNotification.userInfo {
            
            let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            
            keyboardHeight.constant = keyboardFrame.height
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.scrollTableViewToBottom()
            })
        }
    }
    
    func keyboardAway(aNotification: NSNotification) {
        
        if let info = aNotification.userInfo {
            
            keyboardHeight.constant = 0
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.scrollTableViewToBottom()
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = Double(view.frame.size.width)
        let height = Double(view.frame.size.height - formHeight.constant)

        let filledSpace = width + hoot!.replies.doubleValue * CELL_HEIGHT
        
        commentTable.tableFooterView = UIView(frame: CGRect.zeroRect)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //photo.alpha = 1 - (scrollView.contentOffset.y / view.frame.size.width) * 0.5
        blurEffectView?.alpha = (scrollView.contentOffset.y / view.frame.size.width) * 0.6
    }
    
    func commentToSubmit(comment: String) {
        
        HootAPIToCoreData.postComment(comment, hootID: hoot!.id.integerValue) { (success) -> (Void) in
            if(success) {
                HootAPIToCoreData.fetchCommentsForHoot(self.hoot, completed: { (success) -> (Void) in
                    println("new comment so maybe scroll to bottom here after animation")
                })
                self.commentForm.textField.resignFirstResponder()
            } else {
                println("failure submitting comment")
            }
        }
    }
    
    func exitWithoutComment() {
        self.commentForm.textField.resignFirstResponder()
    }
    
    func fetchResultsFromCoreData() {
        let fetchReq = NSFetchRequest(entityName: "HootComment")
        fetchReq.predicate = NSPredicate(format: "hoot == %@", hoot!)
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchReq, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        
        if fetchedResultsController?.performFetch(nil) == false {
            println("fetch failed")
            return
        }
        
        println("fetch succeeded: ordered by time")
        //commentTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    }
    
    func mapResultsControllerIndexToTableViewIndex(index: NSIndexPath?) -> NSIndexPath? {
        if let oldIndex = index {
            return NSIndexPath(forRow: oldIndex.row + 2, inSection: oldIndex.section)
        } else {
            return nil
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        commentTable.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            commentTable.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            commentTable.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Update:
            commentTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        case .Move:
            commentTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        default:
            NSLog("Unknown NSFetchedResultsChangeType")
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        let adjustedIndexPath = self.mapResultsControllerIndexToTableViewIndex(indexPath)
        let adjustedNewIndexPath = self.mapResultsControllerIndexToTableViewIndex(newIndexPath)
        
        
        switch type {
        case .Insert:
            commentTable.insertRowsAtIndexPaths([adjustedNewIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            commentTable.deleteRowsAtIndexPaths([adjustedIndexPath!], withRowAnimation: .Fade)
        case .Update:
            if let cell = commentTable.cellForRowAtIndexPath(adjustedIndexPath!) as? SingleCommentCell {
                let comment = anObject as HootComment
                cell.commentView.setValuesWithComment(comment)
                println("loading \(adjustedIndexPath!.row)")
            }
        case .Move:
            commentTable.deleteRowsAtIndexPaths([adjustedIndexPath!], withRowAnimation: .Fade)
            commentTable.insertRowsAtIndexPaths([adjustedIndexPath!], withRowAnimation: .Fade)
        default:
            NSLog("Unknown NSFetchedResultsChangeType in SingleHootViewController")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        commentTable.endUpdates()
    }
    
    // MARK: - Tableview Delegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return view.frame.size.width
        }
        
        return CGFloat(CELL_HEIGHT)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Add one for the transparent cell and another for the hoot description
        let extraRows = 2
        
        if fetchedResultsController?.sections?.count > 0 {
            if let singleSection = fetchedResultsController?.sections?[section] as? NSFetchedResultsSectionInfo {
                return singleSection.numberOfObjects + extraRows
            } else {
                return extraRows
            }
        } else {
            return extraRows
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Get the clear cell so that we can see the picture behind
        if indexPath.row == 0 {
            return commentTable.dequeueReusableCellWithIdentifier("Clear") as UITableViewCell
        }
        
        let cell = commentTable.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as SingleCommentCell
        
        if indexPath.row == 1 {
            cell.commentView.setValuesWithHoot(hoot!)
            cell.commentView.showReplies(false)
        } else if let singleComment = fetchedResultsController?.objectAtIndexPath(NSIndexPath(forRow: indexPath.row - 2, inSection: indexPath.section)) as? HootComment {
            cell.commentView.setValuesWithComment(singleComment)
        }

        return cell
    }
}