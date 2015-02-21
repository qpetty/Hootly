//
//  SingleHootViewController.swift
//  Hootly
//
//  Created by Quinton Petty on 1/31/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class SingleHootViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    var hoot: Hoot?
    var hootImage: UIImage?
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var commentTable: UITableView!
    @IBOutlet weak var keyboardHeight: NSLayoutConstraint!
    @IBOutlet weak var formHeight: NSLayoutConstraint!
    
    let CELL_HEIGHT = 80.0 as Double
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        photo.image = hootImage
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboard:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboard(aNotification: NSNotification) {

        if let info = aNotification.userInfo {
            
            let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            
            keyboardHeight.constant = keyboardFrame.height
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.layoutIfNeeded()
                let bottomOffset = CGPoint(x: 0, y: self.commentTable.contentSize.height - self.commentTable.bounds.size.height)
                self.commentTable.setContentOffset(bottomOffset, animated: false)
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
        photo.alpha = 1 - (scrollView.contentOffset.y / view.frame.size.width) * 0.5
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return view.frame.size.width
        }
        
        return CGFloat(CELL_HEIGHT)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hoot!.replies.integerValue + 1;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            return commentTable.dequeueReusableCellWithIdentifier("Clear") as UITableViewCell
        }
        
        let cell = commentTable.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as UITableViewCell
        
        return cell
    }
}