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
        
        photo.image = nil
        if let imageURL = singleHoot.photoURL as? NSURL {
            if let urlContents = NSData(contentsOfURL: imageURL) {
                photo.image = UIImage(data: urlContents)
            }
        }
        
        commentView.comment.text = singleHoot.comment
        commentView.rating.text = "\(singleHoot.rating)"
        commentView.replies.text = "\(singleHoot.replies) replies"
        
        let elapsedTime = NSDate().timeIntervalSinceDate(singleHoot.time)

        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Abbreviated
        
        let components = NSDateComponents()
        
        if elapsedTime / (3600 * 24) > 1 {
            components.day = Int(elapsedTime / (3600 * 24))
        } else if elapsedTime / 3600 > 1 {
            components.hour = Int(elapsedTime / 3600)
        } else if elapsedTime / 60 > 1 {
            components.minute = Int(elapsedTime / 60)
        } else {
            components.second = Int(elapsedTime)
        }

        commentView.time.text = formatter.stringFromDateComponents(components)
    }
}