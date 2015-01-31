//
//  SingleHootViewController.swift
//  Hootly
//
//  Created by Quinton Petty on 1/31/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class SingleHootViewController: UIViewController {
    var hoot: Hoot?;
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var commentTable: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        photo.image = hoot?.photo
    }
}