//
//  File.swift
//  Hootly
//
//  Created by Quinton Petty on 1/24/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class Hoot {
    let userID: String
    let photo: UIImage?
    let comment: String
    let replies: Int
    let time: String
    let rating: Int
    
    init(userID: String, photo: UIImage?, comment: String, replies: Int, time: String, rating: Int) {
        self.userID = userID
        self.photo = photo
        self.comment = comment
        self.replies = replies
        self.time = time
        self.rating = rating
    }
}