//
//  Hoot.swift
//  Hootly
//
//  Created by Quinton Petty on 3/22/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import CoreData

@objc(Hoot)

class Hoot: NSManagedObject {

    @NSManaged var comment: String
    @NSManaged var id: NSNumber
    @NSManaged var myHoot: NSNumber
    @NSManaged var photoURL: AnyObject
    @NSManaged var rating: NSNumber
    @NSManaged var replies: NSNumber
    @NSManaged var time: NSDate
    @NSManaged var voted: NSNumber
    @NSManaged var nearby: NSNumber
    @NSManaged var showInHistory: NSNumber
    @NSManaged var comments: NSSet

}
