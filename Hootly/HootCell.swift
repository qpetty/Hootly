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
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var replies: UILabel!
    @IBOutlet weak var time: UILabel!
    
    var hoot: Hoot?
    
    func setHoot(singleHoot: Hoot) {
        hoot = singleHoot
        photo.image = singleHoot.photo
        comment.text = singleHoot.comment
        rating.text = "\(singleHoot.rating)"
        replies.text = "\(singleHoot.replies) replies"
        time.text = singleHoot.time + "m"
    }
}