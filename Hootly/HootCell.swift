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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var hoot: Hoot?
    
    func setHootInfo(singleHoot: Hoot) {
        if hoot != singleHoot {
            hoot = singleHoot
            
            photo.image = nil
            activityIndicator.startAnimating()
            let currentID = hoot?.id
            hoot?.fetchImage({ (image: UIImage) -> (Void) in
                if currentID == self.hoot?.id {
                    self.photo.image = image
                    self.activityIndicator.stopAnimating()
                }
            })
        }
        
        commentView.setValuesWithHoot(hoot!)
    }
}