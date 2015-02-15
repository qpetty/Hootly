//
//  Hoot.swift
//  Hootly
//
//  Created by Quinton Petty on 2/14/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import CoreData

@objc(Hoot)

class Hoot: NSManagedObject {

    @NSManaged var userID: String
    @NSManaged var comment: String
    @NSManaged var time: NSDate
    @NSManaged var rating: NSNumber
    @NSManaged var replies: NSNumber

}
