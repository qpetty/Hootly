//
//  SingleHootViewController.swift
//  Hootly
//
//  Created by Quinton Petty on 1/31/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class SingleHootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var hoot: Hoot?
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var commentTable: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        //photo.image = hoot?.photo
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = commentTable.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as UITableViewCell
        
        return cell
    }
}