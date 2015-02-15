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
    
    var hoot: HootItem?
    
    func setHoot(singleHoot: HootItem) {
        hoot = singleHoot
        //photo.image = singleHoot.photo
        commentView.comment.text = singleHoot.comment
        commentView.rating.text = "\(singleHoot.rating)"
        commentView.replies.text = "\(singleHoot.replies) replies"
        //commentView.time.text = singleHoot.time + "m"
    }
}