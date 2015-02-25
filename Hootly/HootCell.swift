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
        hoot?.fetchImage({ (image: UIImage) -> (Void) in
            self.photo.image = image
        })
        
        commentView.setValuesWithHoot(hoot!)
    }
}