//
//  HootComment.swift
//  Hootly
//
//  Created by Quinton Petty on 3/1/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import CoreData

@objc(HootComment)

class HootComment: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var score: NSNumber
    @NSManaged var text: String
    @NSManaged var time: NSDate
    @NSManaged var voted: NSNumber
    @NSManaged var hoot: Hoot

}
