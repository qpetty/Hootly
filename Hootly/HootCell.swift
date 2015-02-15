//
//  HootCell.swift
//  Hootly
//
//  Created by Quinton Petty on 1/24/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class HootCell: UITableViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var commentView: CommentView!
    
    var hoot: Hoot?
    
    func setHoot(singleHoot: Hoot) {
        hoot = singleHoot
        if let imageURL = singleHoot.photoURL as? NSURL {
            photo.image = UIImage(data: NSData(contentsOfURL: imageURL)!)
        }
        
        commentView.comment.text = singleHoot.comment
        commentView.rating.text = "\(singleHoot.rating)"
        commentView.replies.text = "\(singleHoot.replies) replies"
        
        let elapsedTime = NSDate().timeIntervalSinceDate(singleHoot.time)

        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Abbreviated
        
        let components = NSDateComponents()
        components.second = Int(elapsedTime)

        commentView.time.text = formatter.stringFromDateComponents(components)
    }
}