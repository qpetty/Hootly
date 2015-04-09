//
//  Hoot+ImageForTableView.swift
//  Hootly
//
//  Created by Quinton Petty on 2/17/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

extension Hoot {

    var documentDirectory: String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
    }
    
    var imageDirectoryName: String {
        return "Images"
    }
    
    func fetchImage(fetchedImage: (UIImage) -> (Void)) {
        
        if let imageURL = self.photoURL as? NSURL {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                self.loadImageFromDiskOrNetwork(imageURL, fetchedImage: fetchedImage)
            })
        }
        
    }
    
    private func loadImageFromDiskOrNetwork(imageURL: NSURL, fetchedImage: (UIImage) -> (Void)) {

        // Check to see if the url corresponds to an image on disk or in the network
        if imageURL.fileURL == false {
            let imageSubdirectory = documentDirectory.stringByAppendingPathComponent(imageDirectoryName)
            
            //Check if the image subdirectory has been made, if it hasnt, lets make it!
            let imageDirectoryisPresent = NSFileManager.defaultManager().fileExistsAtPath(imageSubdirectory)
            if imageDirectoryisPresent == false {
                NSFileManager.defaultManager().createDirectoryAtPath(imageSubdirectory, withIntermediateDirectories: true, attributes: nil, error: nil)
            }
            
            //Create the image file
            #if DEBUG
                NSLog("Fetching Image from network \(imageURL)")
            #endif
            if let imageData = NSData(contentsOfURL: imageURL) {
                if let image = UIImage(data: imageData) {
                    //return image
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        fetchedImage(image)
                    })
                    
                    //Write to disk
                    let photoURL = imageSubdirectory.stringByAppendingPathComponent(imageURL.lastPathComponent!)
                    let written = NSFileManager.defaultManager().createFileAtPath(photoURL, contents: imageData, attributes: nil)
                    if written == true {
                        
                        if let writtenPhotoURL = NSURL(fileURLWithPath: photoURL) {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.photoURL = writtenPhotoURL.fileReferenceURL()!
                                self.managedObjectContext?.save(nil)
                            })
                        } else {
                            NSLog("strangly could not get a URL corresponding to \(photoURL)")
                        }

                    } else {
                        NSLog("could not write: \(photoURL)")
                    }
                }
            }
        } else {
            #if DEBUG
                NSLog("Fetching Image from disk \(imageURL)")
            #endif
            if let urlContents = NSData(contentsOfURL: imageURL) {
                if let image = UIImage(data: urlContents) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        fetchedImage(image)
                    })
                }
            } else {
                NSLog("couldn't find url")
            }
        }
    }
}