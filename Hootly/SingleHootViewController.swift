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
    
    let CELL_HEIGHT = 80.0 as Double
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        photo.image = hootImage
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = Double(view.frame.size.width)
        let height = Double(view.frame.size.height)
        
        photo.frame = CGRect(x: 0, y: 0, width: width, height: width)
        
        commentTable.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        
        let filledSpace = width + hoot!.replies.doubleValue * CELL_HEIGHT
        
        var singleView: UIView
        if filledSpace < height {
            singleView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height - filledSpace))
        } else {
            singleView = UIView(frame: CGRect.zeroRect)
        }
        
        singleView.backgroundColor = UIColor.whiteColor()
        commentTable.tableFooterView = singleView
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        photo.alpha = 1 - (scrollView.contentOffset.y / view.frame.size.width)
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